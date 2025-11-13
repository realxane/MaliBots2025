import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/constants/app_text_styles.dart';
import 'package:malibots_challenge_eni/models/product.dart';
import 'package:malibots_challenge_eni/providers/favoris_store.dart';
import 'package:malibots_challenge_eni/routes/app_routes.dart';
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
  final Product product;

  // Images supplémentaires pour alimenter le carousel (optionnel)
  final List<String>? additionalImages;

  // Couleurs disponibles (optionnel, pour afficher une pastille)
  final List<Color>? availableColors;

  // Commentaires (optionnel)
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
  Widget _buildImage(String path) {
    final widget = path.startsWith('http')
        ? Image.network(path, fit: BoxFit.cover, width: double.infinity)
        : Image.asset(path, fit: BoxFit.cover, width: double.infinity);
    return widget;
  }
  int _currentImage = 0;
  Color? _selectedColor;

  // NEW: liste mutable des commentaires dans l'état
  late List<Comment> _comments;

  // NEW: controller pour la saisie
  final TextEditingController _commentCtrl = TextEditingController();

  String _colorToHex(Color c) =>
      '#${c.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';

  Color get brown => AppColors.primary;
  Color get lightBrown => const Color(0xFFF3E6E0);

  List<String> get _images {
    final imgs = <String>[widget.product.imageUrl];
    if (widget.additionalImages != null && widget.additionalImages!.isNotEmpty) {
      imgs.addAll(widget.additionalImages!);
    }
    return imgs.toSet().toList(); // évite les doublons
  }

  @override
  void initState() {
    super.initState();
    final colors = widget.availableColors;
    if (colors != null && colors.isNotEmpty) {
      _selectedColor = colors.first;
    }

    // Initialise la liste des commentaires
    _comments = List<Comment>.from(
      widget.comments ??
          [
            Comment(
              userName: "Le papa de xavier",
              text:
                  "J'ai déjà acheté chez lui et ses produits sont vraiment de bonne qualité !",
            ),
            Comment(
              userName: "Le papa de xavier",
              text:
                  "J'ai déjà acheté chez lui et ses produits sont vraiment de bonne qualité !",
            ),
            Comment(
              userName: "Le papa de xavier",
              text:
                  "J'ai déjà acheté chez lui et ses produits sont vraiment de bonne qualité !",
            ),
          ],
    );
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  // Ouvre une feuille modale pour saisir un commentaire
  void _openAddCommentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Ajouter un commentaire',
                style: TextStyle(fontWeight: FontWeight.w700, color: brown),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _commentCtrl,
                maxLines: 4,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  hintText: 'Votre commentaire…',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final text = _commentCtrl.text.trim();
                        if (text.isEmpty) return;
                        setState(() {
                          _comments.insert(
                            0,
                            Comment(userName: 'Vous', text: text),
                          );
                        });
                        _commentCtrl.clear();
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Commentaire ajouté')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brown,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Publier'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(product.name,
            style: TextStyle(color: brown, fontWeight: FontWeight.w700)),
        iconTheme: IconThemeData(color: brown),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: OutlinedButton(
              onPressed: () {
                final phone = "+22372567555"; 
                if (phone == null || phone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Numéro du vendeur indisponible')),
                  );
                  return;
                }
                _callSeller(context, phone);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: brown,
                backgroundColor: AppColors.textSecondary,
                side: BorderSide(color: brown),
                shape: const StadiumBorder(),
              ),
              child: const Text('Contacter', style: AppTextStyles.button),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CAROUSEL
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  CarouselSlider(
                    items: _images.map((imgPath) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: _buildImage(imgPath)
                      );
                    }).toList(),
                    options: CarouselOptions(
                      viewportFraction: 1,
                      enlargeCenterPage: false,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 4),
                      onPageChanged: (index, reason) {
                        setState(() => _currentImage = index);
                      },
                    ),
                  ),
                  // Indicateurs
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
                            color: active
                                ? brown
                                : Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: brown.withOpacity(0.5), width: 0.6),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            // INFOS
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom + rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: brown),
                        ),
                      ),
                      _Stars(rating: product.rating, color: Colors.amber),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.place, color: brown, size: 18),
                      const SizedBox(width: 6),
                      Text(product.region,
                          style: TextStyle(color: brown.withOpacity(0.8))),
                      const SizedBox(width: 12),
                      Text('•',
                          style: TextStyle(color: brown.withOpacity(0.5))),
                      const SizedBox(width: 12),
                      Icon(Icons.category, color: brown, size: 18),
                      const SizedBox(width: 6),
                      Text(product.type,
                          style: TextStyle(color: brown.withOpacity(0.8))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Artisan: ${product.artisan}',
                      style: TextStyle(color: brown)),

                  const SizedBox(height: 14),
                  // Couleurs disponibles (si fournies)
                  if ((widget.availableColors?.isNotEmpty ?? false)) ...[
                    Text('Couleurs disponible',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, color: brown)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      children: widget.availableColors!
                          .map(
                            (c) => GestureDetector(
                              onTap: () => setState(() => _selectedColor = c),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _selectedColor == c
                                        ? brown
                                        : Colors.grey.shade300,
                                    width: _selectedColor == c ? 2 : 1,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Prix
                  Row(
                    children: [
                      Text(
                        'Prix : ${product.price} F',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: brown),
                      ),
                      const Spacer(),
                      Icon(Icons.favorite_border, color: brown),
                      const SizedBox(width: 6),
                      Text('${product.likes}', style: TextStyle(color: brown)),
                    ],
                  ),
                ],
              ),
            ),

            // COMMENTAIRES
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Commentaires',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: brown)),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: _comments
                    .map(
                      (c) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: lightBrown,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: brown,
                              foregroundColor: Colors.white,
                              child: const Icon(Icons.person, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.userName,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: brown)),
                                  const SizedBox(height: 4),
                                  Text(c.text),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 90), // espace pour le bouton bas
          ],
        ),
      ),

      // BOUTON BAS FIXE
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bouton "Ajouter un commentaire" AU-DESSUS
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _openAddCommentSheet,
                  icon: Icon(Icons.add_comment, color: brown),
                  label: Text(
                    'Ajouter un commentaire',
                    style: TextStyle(
                        color: brown, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: brown),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Ligne favoris + panier (existant)
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      final store = context.read<FavoritesStore>();
                      if (!store.isProductFavorite(product.id)) {
                        store.toggleProduct(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  '${product.name} ajouté aux favoris')),
                        );
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const FavoritesPage()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      shape: const CircleBorder(),
                      side: BorderSide(color: brown),
                      foregroundColor: brown,
                      padding: const EdgeInsets.all(10),
                    ),
                    child: const Icon(Icons.favorite_border),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final hasColors =
                            (widget.availableColors?.isNotEmpty ?? false) &&
                                _selectedColor != null;
                        final colorHex =
                            hasColors ? _colorToHex(_selectedColor!) : null;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  '${product.name} ajouté au panier !')),
                        );

                        CartController.I.addItem(
                          productId: product.id,
                          name: product.name,
                          color: colorHex, // <- null si pas de couleur
                          price: product.price,
                          assetImagePath: product.imageUrl,
                          qty: 1,
                        );

                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const CartPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Ajouter au panier'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget pour les étoiles de rating
class _Stars extends StatelessWidget {
  final double rating;
  final Color color;
  const _Stars({required this.rating, required this.color});

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final hasHalf = (rating - full) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < full) return Icon(Icons.star, color: color, size: 20);
        if (i == full && hasHalf) return Icon(Icons.star_half, color: color, size: 20);
        return Icon(Icons.star_border, color: color, size: 20);
      }),
    );
  }
}

Future<void> _callSeller(BuildContext context, String phone) async {
  final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
  if (cleaned.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Numéro indisponible')),
    );
    return;
  }

  final uri = Uri(scheme: 'tel', path: cleaned);

  final ok = await launchUrl(
    uri,
    mode: LaunchMode.externalApplication, // ouvre l’app Téléphone
  );

  if (!ok) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Impossible d’ouvrir l’app Téléphone')),
    );
  }
}