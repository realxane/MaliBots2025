import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_text_styles.dart';
import 'produit.dart';
import 'modifie_produit.dart';

const Color bogolan = Color(0xFF7B3F00);
const Color accent = Color(0xFFCC4B00);
const Color pale = Color(0xFFF2E9D0);

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  List<Product> products = [
    Product(
      id: 'p1',
      name: 'Bazin traditionnel',
      description: 'Tissu bazin du sud, haute qualité',
      price: 18000,
      stock: 10,
      images: [],
      region: 'Bamako',
      category: 'Tenue',
      color: 'Bogolan',
    ),
  ];

  int ventes = 120;
  int favoris = 80;
  int notes = 95;
  int avis = 30;

  final Random _random = Random();

  Future<void> _openAdd() async {
    final res = await Navigator.push<Product?>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
    );
    if (res != null) setState(() => products.insert(0, res));
  }

  Future<void> _openEdit(Product p) async {
    final res = await Navigator.push<Product?>(
      context,
      MaterialPageRoute(builder: (_) => AddEditProductScreen(product: p)),
    );
    if (res != null) {
      setState(() {
        final idx = products.indexWhere((e) => e.id == p.id);
        if (idx >= 0) products[idx] = res;
      });
    }
  }

  void _delete(Product p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer le produit ?'),
        content: Text('Voulez-vous vraiment supprimer "${p.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: bogolan),
            onPressed: () {
              setState(() => products.removeWhere((e) => e.id == p.id));
              Navigator.pop(context);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _increaseStock(Product p) {
    setState(() {
      final idx = products.indexWhere((e) => e.id == p.id);
      if (idx >= 0)
        products[idx] = products[idx].copyWith(stock: products[idx].stock + 1);
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

  // NE PAS TOUCHER (comme demandé)
  Widget _statBar(String label, int value, Color color, double ratio) {
    double dynamicRatio = (value / 150).clamp(0.1, 1.0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 48,
          height: 160 * dynamicRatio,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(value.toString()),
      ],
    );
  }

  Widget _productCard(Product p) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: p.images.isNotEmpty
                  ? Image.file(
                      File(p.images.first),
                      width: 85,
                      height: 85,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/images/tenu1.jpg',
                      width: 85,
                      height: 85,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.brown.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: p.color,
                          underline: const SizedBox.shrink(),
                          items: ['Bogolan', 'Rouge', 'Bleu', 'Vert', 'Marron']
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              final idx = products.indexWhere(
                                (e) => e.id == p.id,
                              );
                              if (idx >= 0)
                                products[idx] = products[idx].copyWith(
                                  color: val!,
                                );
                            });
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
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Text(p.stock.toString()),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => _increaseStock(p),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: bogolan,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Prix : ${p.price.toInt()} f',
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
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
    // Seules lignes ajoutées: on lit le thème courant
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final titleStyle = TextStyle(
      color: bogolan, // en clair: identique à avant
      fontWeight: FontWeight.bold,
      fontSize: 18,
    );

    return Scaffold(
      // en clair: blanc, en sombre: background du thème
      backgroundColor: isDark ? cs.background : Colors.white,
      appBar: AppBar(
        // en clair: blanc, en sombre: surface du thème
        backgroundColor: isDark ? cs.surface : Colors.white,
        elevation: 0,
        leading: IconButton(
          // en clair: noir87 (strictement identique), en sombre: onSurface
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? cs.onSurface : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Tableau de bord', style: AppTextStyles.titre1),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Zone Statistiques
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // en clair: blanc identique, en sombre: surface
                color: isDark ? cs.surface : Colors.white,
                borderRadius: BorderRadius.circular(12),
                // en clair: même shadow qu’avant, en sombre: pas d’ombre claire
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Statistiques', style: titleStyle),
                      IconButton(
                        onPressed: _refreshStats,
                        icon: Icon(Icons.refresh, color: bogolan),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // NE PAS TOUCHER aux barres
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _statBar('Ventes', ventes, const Color(0xFF7B2B00), 0.86),
                      _statBar('Favoris', favoris, accent, 0.62),
                      _statBar('Notes', notes, const Color(0xFFFBB800), 0.78),
                      _statBar('Avis', avis, const Color(0xFF6B4436), 0.4),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Text('Produits récents', style: titleStyle),
            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (_, i) => _productCard(products[i]),
              ),
            ),
          ],
        ),
      ),

      // FAB: on garde ta couleur (identique en clair)
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        backgroundColor: bogolan,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}