// lib/screens/catalogue/app_produit_detail.dart
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/constants/app_text_styles.dart';
import 'package:malibots_challenge_eni/models/product.dart';
import 'package:malibots_challenge_eni/providers/favoris_store.dart';
import 'package:malibots_challenge_eni/screens/catalogue/app_panier.dart';
import 'package:malibots_challenge_eni/screens/favoris/app_favoris.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

class Comment {
  final String userName;
  final String text;
  Comment({required this.userName, required this.text});
}

class ProductDetailPage extends StatefulWidget {
  final Produit product;
  final List<String>? additionalImages;
  final List<Color>? availableColors;
  final List<Comment>? comments;

  const ProductDetailPage({
    super.key,
    required this.product,
    this.additionalImages,
    this.availableColors,
    this.comments,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _currentImage = 0;
  Color? _selectedColor;

  late List<Comment> _comments;
  final TextEditingController _commentCtrl = TextEditingController();

  List<String> get _images {
    final imgs = <String>[widget.product.imageBest];
    if ((widget.additionalImages?.isNotEmpty ?? false)) {
      imgs.addAll(widget.additionalImages!);
    }
    return imgs.toSet().toList();
  }

  @override
  void initState() {
    super.initState();
    final colors = widget.availableColors;
    if (colors != null && colors.isNotEmpty) {
      _selectedColor = colors.first;
    }
    _comments = List<Comment>.from(
      widget.comments ??
          [
            Comment(userName: "Client", text: "Très bon produit !"),
          ],
    );
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Widget _buildImage(String path) {
    return path.startsWith('http')
        ? Image.network(path, fit: BoxFit.cover, width: double.infinity)
        : Image.asset(path, fit: BoxFit.cover, width: double.infinity);
  }

  String _colorToHex(Color c) => '#${c.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';

  void _openAddCommentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final cs = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;
        final accent = isDark ? cs.primary : AppColors.primary;

        return Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: MediaQuery.of(ctx).viewInsets.bottom + 16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Ajouter un commentaire', style: TextStyle(fontWeight: FontWeight.w700, color: accent)),
            const SizedBox(height: 8),
            TextField(controller: _commentCtrl, maxLines: 4, textInputAction: TextInputAction.done, decoration: const InputDecoration(hintText: 'Votre commentaire…', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Annuler'))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(
                onPressed: () {
                  final text = _commentCtrl.text.trim();
                  if (text.isEmpty) return;
                  setState(() { _comments.insert(0, Comment(userName: 'Vous', text: text)); });
                  _commentCtrl.clear();
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Commentaire ajouté')));
                },
                style: ElevatedButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.white),
                child: const Text('Publier'),
              )),
            ]),
          ]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final accent = isDark ? cs.primary : AppColors.primary;
    final surface = isDark ? cs.surface : Colors.white;
    final onSurface = isDark ? cs.onSurface : accent;
    final subtle = isDark ? cs.onSurfaceVariant : Colors.brown.shade300;
    final chipBg = isDark ? cs.surfaceVariant.withOpacity(0.6) : const Color(0xFFF3E6E0);

    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0.5,
        title: Text(p.nom, style: TextStyle(color: onSurface, fontWeight: FontWeight.w700)),
        iconTheme: IconThemeData(color: onSurface),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: OutlinedButton(
              onPressed: () => _callSeller(context, "+22372567555"),
              style: OutlinedButton.styleFrom(
                foregroundColor: accent,
                backgroundColor: isDark ? cs.surfaceVariant : AppColors.textSecondary,
                side: BorderSide(color: accent),
                shape: const StadiumBorder(),
              ),
              child: const Text('Contacter', style: AppTextStyles.button),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(alignment: Alignment.bottomCenter, children: [
              CarouselSlider(
                items: _images.map((imgPath) => ClipRRect(borderRadius: BorderRadius.circular(6), child: _buildImage(imgPath))).toList(),
                options: CarouselOptions(
                  viewportFraction: 1, enlargeCenterPage: false, autoPlay: true, autoPlayInterval: const Duration(seconds: 4),
                  onPageChanged: (index, reason) => setState(() => _currentImage = index),
                ),
              ),
              Positioned(
                bottom: 8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_images.length, (index) {
                    final active = index == _currentImage;
                    return Container(
                      width: active ? 22 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: active ? accent : (isDark ? cs.onSurfaceVariant : Colors.white.withOpacity(0.8)),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: accent.withOpacity(0.5), width: 0.6),
                      ),
                    );
                  }),
                ),
              ),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(p.nom, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: accent))),
                _Stars(rating: p.ratingSafe, color: Colors.amber),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.place, color: accent, size: 18),
                const SizedBox(width: 6),
                Text(p.regionLabel, style: TextStyle(color: isDark ? cs.onSurface : accent.withOpacity(0.8))),
                const SizedBox(width: 12),
                Text('•', style: TextStyle(color: isDark ? cs.onSurfaceVariant : accent.withOpacity(0.5))),
                const SizedBox(width: 12),
                Icon(Icons.category, color: accent, size: 18),
                const SizedBox(width: 6),
                Text(p.typeUi, style: TextStyle(color: isDark ? cs.onSurface : accent.withOpacity(0.8))),
              ]),
              const SizedBox(height: 6),
              Text('Artisan: ${p.artisan ?? '—'}', style: TextStyle(color: isDark ? cs.onSurface : accent)),
              const SizedBox(height: 14),
              Row(children: [
                Text('Prix : ${p.prixInt} F', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: accent)),
                const Spacer(),
                Icon(Icons.favorite_border, color: accent),
                const SizedBox(width: 6),
                Text('${p.likesSafe}', style: TextStyle(color: isDark ? cs.onSurface : accent)),
              ]),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Commentaires', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: accent)),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(children: _comments.map((c) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: chipBg, borderRadius: BorderRadius.circular(10)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CircleAvatar(backgroundColor: accent, foregroundColor: Colors.white, child: const Icon(Icons.person, size: 18)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.userName, style: TextStyle(fontWeight: FontWeight.w700, color: accent)),
                  const SizedBox(height: 4),
                  Text(c.text, style: TextStyle(color: isDark ? cs.onSurface : Colors.black87)),
                ])),
              ]),
            )).toList()),
          ),
          const SizedBox(height: 90),
        ]),
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          color: surface,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openAddCommentSheet,
                icon: Icon(Icons.add_comment, color: accent),
                label: Text('Ajouter un commentaire', style: TextStyle(color: accent, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(side: BorderSide(color: accent), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              OutlinedButton(
                onPressed: () {
                  final store = context.read<FavoritesStore>();
                  if (!store.isProductFavorite(p.id)) {
                    store.toggleProduct(p);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${p.nom} ajouté aux favoris')));
                  }
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FavoritesPage()));
                },
                style: OutlinedButton.styleFrom(shape: const CircleBorder(), side: BorderSide(color: accent), foregroundColor: accent, padding: const EdgeInsets.all(10)),
                child: const Icon(Icons.favorite_border),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${p.nom} ajouté au panier !')));
                    CartController.I.addItem(
                      productId: p.id, name: p.nom, color: null, price: p.prixInt, assetImagePath: p.imageBest, qty: 1,
                    );
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartPage()));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: const Text('Ajouter au panier'),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  final double rating; // 0..5
  final Color color;
  const _Stars({required this.rating, required this.color});
  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final hasHalf = (rating - full) >= 0.5;
    return Row(mainAxisSize: MainAxisSize.min, children: List.generate(5, (i) {
      if (i < full) return Icon(Icons.star, color: color, size: 20);
      if (i == full && hasHalf) return Icon(Icons.star_half, color: color, size: 20);
      return Icon(Icons.star_border, color: color, size: 20);
    }));
  }
}

Future<void> _callSeller(BuildContext context, String phone) async {
  final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
  if (cleaned.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Numéro indisponible')));
    return;
  }
  final uri = Uri(scheme: 'tel', path: cleaned);
  // ignore: use_build_context_synchronously
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible d’ouvrir l’app Téléphone')));
  }
}