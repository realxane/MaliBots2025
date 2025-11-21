import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:malibots_challenge_eni/constants/app_text_styles.dart';
import 'package:malibots_challenge_eni/models/product.dart';
import 'package:malibots_challenge_eni/screens/home/vendeurpages/modifie_produit.dart';
import 'package:malibots_challenge_eni/services/produit_service.dart';
// normalisation partagée
import 'package:malibots_challenge_eni/utils/image_urls.dart';

const Color bogolan = Color(0xFF7B3F00);
const Color accent = Color(0xFFCC4B00);
const Color pale = Color(0xFFF2E9D0);

// Helpers locaux
bool _isHttp(String s) => s.startsWith('http://') || s.startsWith('https://');
bool _isFilePath(String s) => s.startsWith('/') || s.startsWith('file://');
bool _isAsset(String s) => s.startsWith('assets/');
bool _isDataUri(String s) => s.startsWith('data:image/');

Uint8List? tryDecodeInlineImage(String src) {
  try {
    if (_isDataUri(src)) {
      final base64Part = src.split(',').last;
      return base64Decode(base64Part);
    }
    if (src.length > 100 &&
        RegExp(r'^[A-Za-z0-9+/=\r\n]+$').hasMatch(src)) {
      return base64Decode(src);
    }
    return null;
  } catch (_) {
    return null;
  }
}

ImageProvider<Object>? tryImageProvider(String raw) {
  final p = normalizeImageRef(raw.trim());
  if (p.isEmpty) return null;

  if (_isHttp(p)) return NetworkImage(p);

  final mem = tryDecodeInlineImage(p);
  if (mem != null) return MemoryImage(mem);

  if (_isFilePath(p)) {
    final path = p.startsWith('file://') ? Uri.parse(p).toFilePath() : p;
    return FileImage(File(path));
  }

  if (_isAsset(p)) return AssetImage(p);

  return null;
}

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  List<Produit> products = [];
  final Map<String, String> _uiColors = {};

  int ventes = 120;
  int favoris = 80;
  int notes = 95;
  int avis = 30;

  final Random _random = Random();
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = context.read<ProduitService>();
      final list = await service.fetchMyProducts(perPage: 100);

      setState(() {
        products = list;
        // couleur par défaut
        for (final p in list) {
          _uiColors[p.id] = _uiColors[p.id] ?? 'Bogolan';
        }
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openAdd() async {
    final res = await Navigator.push<Produit?>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
    );
    if (res != null) {
      // On recharge depuis le backend pour rester cohérent
      await _loadProducts();
    }
  }

  Future<void> _openEdit(Produit p) async {
    final res = await Navigator.push<Produit?>(
      context,
      MaterialPageRoute(builder: (_) => AddEditProductScreen(product: p)),
    );
    if (res != null) {
      await _loadProducts();
    }
  }

  void _delete(Produit p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer le produit ?'),
        content: Text('Voulez-vous vraiment supprimer "${p.nom}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: bogolan),
            onPressed: () {
              setState(() {
                products.removeWhere((e) => e.id == p.id);
                _uiColors.remove(p.id);
              });
              Navigator.pop(context);
              // Optionnel: appeler le backend pour supprimer réellement
              // via ProduitService (non inclus ici).
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _increaseStock(Produit p) {
    setState(() {
      final idx = products.indexWhere((e) => e.id == p.id);
      if (idx >= 0) {
        final current = products[idx].stock ?? 0;
        products[idx] = products[idx].copyWith(stock: current + 1);
      }
    });
  }

  void _refreshStats() {
    setState(() {
      ventes = 80 + _random.nextInt(100);
      favoris = 40 + _random.nextInt(80);
      notes = 60 + _random.nextInt(50);
      avis = 10 + _random.nextInt(60);
    });
  }

  // -------- Helpers images
  String _bestImage(Produit p) {
    // Utilise le getter défini dans extension ProduitUi
    return p.imageBest.trim();
  }

  Widget _placeholderImg({double w = 85, double h = 85}) => Image.asset(
        'assets/images/tenu1.jpg',
        width: w,
        height: h,
        fit: BoxFit.cover,
        key: const ValueKey('asset_fallback'),
      );

  Widget _productImage(Produit p, {double w = 85, double h = 85}) {
    final best = normalizeImageRef(_bestImage(p));
    if (best.isEmpty) {
      debugPrint('ℹ️ ${p.id}: images vides -> placeholder');
      return _placeholderImg(w: w, h: h);
    }

    final provider = tryImageProvider(best);
    if (provider == null) {
      debugPrint(
          '⚠️ ${p.id}: référence image non supportée "$best" -> placeholder');
      return _placeholderImg(w: w, h: h);
    }

    return Image(
      image: provider,
      width: w,
      height: h,
      fit: BoxFit.cover,
      key: ValueKey('img_${p.id}_$best'),
      errorBuilder: (_, err, ___) {
        debugPrint(
            '❌ ${p.id}: échec rendu image "$best": $err -> placeholder');
        return _placeholderImg(w: w, h: h);
      },
    );
  }

  Widget _productCard(Produit p) {
    final currentUiColor = _uiColors[p.id] ?? 'Bogolan';
    final best = _bestImage(p);

    return Card(
      key: ValueKey('card_${p.id}_$best'),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _productImage(p),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.nom,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.brown.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: currentUiColor,
                          underline: const SizedBox.shrink(),
                          items: const [
                            'Bogolan',
                            'Rouge',
                            'Bleu',
                            'Vert',
                            'Marron'
                          ]
                              .map((c) =>
                                  DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (val) {
                            if (val == null) return;
                            setState(() => _uiColors[p.id] = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Stock: '),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Text((p.stock ?? 0).toString()),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => _increaseStock(p),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: bogolan,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.add,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Prix : ${p.prixInt} f',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Column(
              children: [
                IconButton(
                  onPressed: () => _openEdit(p),
                  icon: const Icon(Icons.edit, color: bogolan),
                ),
                IconButton(
                  onPressed: () => _delete(p),
                  icon:
                      const Icon(Icons.delete, color: Colors.redAccent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final titleStyle = const TextStyle(
      color: bogolan,
      fontWeight: FontWeight.bold,
      fontSize: 18,
    );

    return Scaffold(
      backgroundColor: isDark ? cs.background : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? cs.surface : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? cs.onSurface : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Tableau de bord', style: AppTextStyles.titre1),
        centerTitle: true,
      ),
      body: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistiques
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? cs.surface : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 10,
                        ),
                      ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Statistiques', style: titleStyle),
                      IconButton(
                        onPressed: _refreshStats,
                        icon: const Icon(Icons.refresh,
                            color: bogolan),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _statBar(
                          'Ventes', ventes, const Color(0xFF7B2B00), 0.86),
                      _statBar('Favoris', favoris, accent, 0.62),
                      _statBar('Notes', notes,
                          const Color(0xFFFBB800), 0.78),
                      _statBar('Avis', avis,
                          const Color(0xFF6B4436), 0.4),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text('Produits récents', style: titleStyle),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : products.isEmpty
                          ? const Center(
                              child: Text('Aucun produit publié pour le moment.'),
                            )
                          : ListView.builder(
                              itemCount: products.length,
                              itemBuilder: (_, i) =>
                                  _productCard(products[i]),
                            ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        backgroundColor: bogolan,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  // Barres
  Widget _statBar(
      String label, int value, Color color, double ratio) {
    final dynamicRatio = (value / 150).clamp(0.1, 1.0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 48,
          height: 160 * dynamicRatio,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(8)),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(value.toString()),
      ],
    );
  }
}