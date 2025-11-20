import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/providers/product_store.dart';
import 'package:malibots_challenge_eni/routes/app_routes.dart';
import 'package:malibots_challenge_eni/screens/catalogue/app_produit_detail.dart';
import 'package:malibots_challenge_eni/widgets/buttons/bouton_retour.dart';
import 'package:provider/provider.dart';

/// ----------------------
/// Modèles et contrôleur
/// ----------------------

class CartItem {
  CartItem({
    required this.productId,
    required this.name,
    this.color, // hex (#A0522D) ou nom
    required this.price, // en unités (ex: 18000 pour 18000f)
    required this.assetImagePath, // peut être asset OU URL
    this.qty = 1,
  });

  final String productId;
  final String name;
  final String? color;
  final int price;
  final String assetImagePath; // asset path OU URL
  int qty;

  String get key => (color == null || color!.isEmpty)
      ? productId
      : '$productId|$color';
}

class CartController extends ChangeNotifier {
  CartController._();
  static final CartController I = CartController._();

  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList(growable: false);

  int get total => _items.values.fold(0, (sum, it) => sum + it.price * it.qty);

  void addItem({
    required String productId,
    required String name,
    String? color,
    required int price,
    required String assetImagePath, // accepte aussi des URLs
    int qty = 1,
  }) {
    // On accepte désormais aussi les URLs (plus d'assert bloquante).
    final temp = CartItem(
      productId: productId,
      name: name,
      color: color,
      price: price,
      assetImagePath: assetImagePath,
      qty: qty,
    );
    final k = temp.key;
    if (_items.containsKey(k)) {
      _items[k]!.qty += qty;
    } else {
      _items[k] = temp;
    }
    notifyListeners();
  }

  void increment(String key) {
    final it = _items[key];
    if (it == null) return;
    it.qty++;
    notifyListeners();
  }

  void decrement(String key) {
    final it = _items[key];
    if (it == null) return;
    if (it.qty > 1) {
      it.qty--;
    } else {
      _items.remove(key);
    }
    notifyListeners();
  }

  void remove(String key) {
    _items.remove(key);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

/// ----------------------
/// Page Panier (UI)
/// ----------------------

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final surface = isDark ? cs.surface : Colors.white;
    final onSurface = isDark ? cs.onSurface : AppColors.textSecondary;
    final accent = isDark ? cs.primary : AppColors.textSecondary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0.5,
        leading: Navigator.canPop(context)
            ? fleche_retour(
                onPressed: () {
                  Navigator.of(context).maybePop();
                },
              )
            : null,
        title: const Text('Mon panier'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: CartController.I,
        builder: (context, _) {
          final items = CartController.I.items;
          if (items.isEmpty) {
            return const Center(
              child: Text('Votre panier est vide.'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final it = items[index];
                    return _CartRow(item: it, accent: accent);
                  },
                ),
              ),
              _CartBottomBar(accent: accent),
            ],
          );
        },
      ),
    );
  }
}

class _CartRow extends StatelessWidget {
  const _CartRow({required this.item, required this.accent});

  final CartItem item;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final key = item.key;
    final swatch = _parseColor(item.color);

    void _openDetails() {
      final products = context.read<ProductsStore>();
      final product = products.byId(item.productId);
      if (product == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produit introuvable')),
        );
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProductDetailPage(product: product),
        ),
      );
    }

    Widget _image(String path) {
      final isUrl = path.startsWith('http');
      final img = isUrl
          ? Image.network(path, width: 88, height: 88, fit: BoxFit.cover)
          : Image.asset(path, width: 88, height: 88, fit: BoxFit.cover);
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: img,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openDetails, // Rend toute la ligne cliquable
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _image(item.assetImagePath),
              const SizedBox(width: 10),
              // Infos produit
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ligne titre + supprimer
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.all(4),
                          icon: Icon(Icons.close, color: cs.onSurfaceVariant),
                          onPressed: () => CartController.I.remove(key),
                          tooltip: 'Supprimer',
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Couleur
                    if (item.color != null && item.color!.isNotEmpty)
                      Row(
                        children: [
                          const Text('Couleur  '),
                          if (swatch != null)
                            Container(
                              width: 36,
                              height: 12,
                              decoration: BoxDecoration(
                                color: swatch,
                                borderRadius: BorderRadius.circular(2),
                                border: Border.all(color: cs.outlineVariant),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: cs.outlineVariant),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.color!, // label texte (ex: "Marron")
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 6),
                    // Prix + quantité
                    Row(
                      children: [
                        Text(
                          'Prix : ${_formatMoney(item.price)}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        _QtyControl(
                          qty: item.qty,
                          accent: accent,
                          onMinus: () => CartController.I.decrement(key),
                          onPlus: () => CartController.I.increment(key),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QtyControl extends StatelessWidget {
  const _QtyControl({
    required this.qty,
    required this.accent,
    required this.onMinus,
    required this.onPlus,
  });

  final int qty;
  final Color accent;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final border = BorderSide(color: accent, width: 1);
    final radius = BorderRadius.circular(4);
    return Row(
      children: [
        InkWell(
          onTap: onMinus,
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: border, top: border, bottom: border),
              borderRadius: BorderRadius.only(
                topLeft: radius.topLeft,
                bottomLeft: radius.bottomLeft,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Text('−', style: TextStyle(color: accent, fontSize: 16)),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: accent,
            border: Border(top: border, bottom: border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text(
            '$qty',
            style: TextStyle(
              color: cs.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        InkWell(
          onTap: onPlus,
          child: Container(
            decoration: BoxDecoration(
              border: Border(right: border, top: border, bottom: border),
              borderRadius: BorderRadius.only(
                topRight: radius.topRight,
                bottomRight: radius.bottomRight,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Text('+', style: TextStyle(color: accent, fontSize: 16)),
          ),
        ),
      ],
    );
  }
}

class _CartBottomBar extends StatelessWidget {
  const _CartBottomBar({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total = CartController.I.total;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(top: BorderSide(color: cs.outlineVariant)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Total : ${_formatMoney(total)}',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Panier validé')),
                    );
                    Navigator.pushNamed(context, AppRoutes.choixmodepayemnt);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text('Valider le panier'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ----------------------
/// Helpers
/// ----------------------

String _formatMoney(int value) {
  final s = value.toString();
  final re = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  final formatted = s.replaceAllMapped(re, (m) => '${m[1]} ');
  return '${formatted} FCFA';
}

Color? _parseColor(String? input) {
  if (input == null) return null;
  // Accepte "#RRGGBB" ou "#AARRGGBB"
  final hex = input.replaceAll('#', '');
  if (hex.length == 6) {
    return Color(int.parse('FF$hex', radix: 16));
  } else if (hex.length == 8) {
    return Color(int.parse(hex, radix: 16));
  }
  return null; // si ce n'est pas un hex, on n'affiche qu'un label
}