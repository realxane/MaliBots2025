// lib/screens/catalogue/app_panier.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/providers/product_store.dart';
import 'package:malibots_challenge_eni/providers/favoris_store.dart';
import 'package:malibots_challenge_eni/routes/app_routes.dart';
import 'package:malibots_challenge_eni/screens/catalogue/app_produit_detail.dart';
import 'package:malibots_challenge_eni/services/cart_api.dart';
import 'package:malibots_challenge_eni/widgets/buttons/bouton_retour.dart';
import 'package:provider/provider.dart';
import 'package:malibots_challenge_eni/utils/context_x.dart';

/// ----------------------
/// Modèles et contrôleur
/// ----------------------

class CartItem {
  CartItem({
    required this.productId,
    required this.name,
    this.color,
    required this.price,
    required this.assetImagePath,
    this.qty = 1,
    this.serverItemId,
  });

  final String productId;
  final String name;
  final String? color;
  final int price;
  final String assetImagePath;
  int qty;

  String? serverItemId;

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

  void clear() {
    _items.clear();
    notifyListeners();
  }

  void addItem({
    required String productId,
    required String name,
    String? color,
    required int price,
    required String assetImagePath,
    int qty = 1,
    String? serverItemId,
  }) {
    final temp = CartItem(
      productId: productId,
      name: name,
      color: color,
      price: price,
      assetImagePath: assetImagePath,
      qty: qty,
      serverItemId: serverItemId,
    );
    final k = temp.key;
    if (_items.containsKey(k)) {
      _items[k]!.qty += qty;
      _items[k]!.serverItemId ??= serverItemId;
    } else {
      _items[k] = temp;
    }
    notifyListeners();
  }

  void attachServerItemId(String key, String serverItemId) {
    final it = _items[key];
    if (it == null) return;
    it.serverItemId = serverItemId;
    notifyListeners();
  }

  void setQty(String key, int qty) {
    final it = _items[key];
    if (it == null) return;
    if (qty <= 0) {
      _items.remove(key);
    } else {
      it.qty = qty;
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
}

/// ----------------------
/// Page Panier (UI)
/// ----------------------

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _loading = true;
  String? _error;

  Future<void> _hydrateFromServer() async {
    try {
      final api = CartApi(baseUrl: context.apiBaseUrl);
      final serverCart = await api.getCart();

      CartController.I.clear();
      for (final it in serverCart.items) {
        CartController.I.addItem(
          productId: it.produitId,
          name: it.nom,
          price: it.price,
          assetImagePath: it.imageUrlBest,
          qty: it.quantite,
          serverItemId: it.itemId,
        );
      }
      _error = null;
    } catch (e) {
      _error = _prettyNetworkError(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    // Lance l’hydratation après le premier frame (context prêt)
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrateFromServer());
  }

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
                onPressed: () => Navigator.of(context).maybePop(),
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Erreur de synchronisation: $_error'))
              : AnimatedBuilder(
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

    Future<void> _serverUpdateQty(int newQty) async {
      final api = CartApi(baseUrl: context.apiBaseUrl);

      final id = item.serverItemId;
      if (id == null || id.isEmpty) {
        final cart = await api.getCart();
        final match = cart.items.firstWhere(
          (e) => e.produitId == item.productId,
          orElse: () => throw Exception('Item serveur introuvable'),
        );
        CartController.I.attachServerItemId(key, match.itemId);
        await api.updateItemQty(itemId: match.itemId, quantite: newQty);
      } else {
        await api.updateItemQty(itemId: id, quantite: newQty);
      }
    }

    Future<void> _serverDelete() async {
      final api = CartApi(baseUrl: context.apiBaseUrl);
      final id = item.serverItemId;
      if (id != null && id.isNotEmpty) {
        await api.removeItem(itemId: id);
      } else {
        final cart = await api.getCart();
        final match = cart.items.firstWhere(
          (e) => e.produitId == item.productId,
          orElse: () => throw Exception('Item serveur introuvable'),
        );
        await api.removeItem(itemId: match.itemId);
      }
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
        onTap: _openDetails,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _image(item.assetImagePath),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          onPressed: () async {
                            final old = item.qty;
                            CartController.I.remove(key);
                            try {
                              await _serverDelete();
                            } catch (e) {
                              CartController.I.addItem(
                                productId: item.productId,
                                name: item.name,
                                color: item.color,
                                price: item.price,
                                assetImagePath: item.assetImagePath,
                                qty: old,
                                serverItemId: item.serverItemId,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erreur suppression: $e')),
                              );
                            }
                          },
                          tooltip: 'Supprimer',
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
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
                                item.color!,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 6),
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
                          onMinus: () async {
                            final newQty = item.qty - 1;
                            final oldQty = item.qty;
                            CartController.I.decrement(key);
                            try {
                              await _serverUpdateQty(newQty);
                            } catch (e) {
                              CartController.I.setQty(key, oldQty);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erreur: $e')),
                              );
                            }
                          },
                          onPlus: () async {
                            final newQty = item.qty + 1;
                            final oldQty = item.qty;
                            CartController.I.increment(key);
                            try {
                              await _serverUpdateQty(newQty);
                            } catch (e) {
                              CartController.I.setQty(key, oldQty);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erreur: $e')),
                              );
                            }
                          },
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
  final hex = input.replaceAll('#', '');
  if (hex.length == 6) {
    return Color(int.parse('FF$hex', radix: 16));
  } else if (hex.length == 8) {
    return Color(int.parse(hex, radix: 16));
  }
  return null;
}

// --------- message d'erreur réseau plus clair ---------
String _prettyNetworkError(Object e) {
  if (e is TimeoutException ||
      e.toString().contains('TimeoutException')) {
    return 'Délai dépassé. Le serveur ne répond pas.';
  }
  final msg = e.toString();
  if (msg.contains('SocketException')) {
    return 'Serveur injoignable. Vérifiez le Wi‑Fi, l’IP et le port.';
  }
  return msg;
}