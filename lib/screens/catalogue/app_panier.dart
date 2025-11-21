import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/providers/product_store.dart';
import 'package:malibots_challenge_eni/routes/app_routes.dart';
import 'package:malibots_challenge_eni/screens/catalogue/app_produit_detail.dart';
import 'package:malibots_challenge_eni/screens/paiements/PaiementController.dart';
import 'package:malibots_challenge_eni/screens/paiements/choix_mode.dart';
import 'package:malibots_challenge_eni/widgets/buttons/bouton_retour.dart';
import 'package:provider/provider.dart';
import 'package:malibots_challenge_eni/models/product.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// ----------------------
/// Modèles et contrôleur
/// ----------------------

class CartItem {
  CartItem({
    required this.productId,
    required this.name,
    this.color, // hex (#A0522D) ou nom
    required this.price, // en unités (ex: 18000 pour 18000f)
    required this.assetImagePath,
    this.qty = 1,
  });

  final String productId;
  final String name;
  final String? color;
  final int price;
  final String assetImagePath;
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
    required String assetImagePath,
    int qty = 1,
  }) {
    assert(!assetImagePath.startsWith('http'),
        'CartController n’accepte que des assets locaux pour les images.');
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
    final brown = AppColors.textSecondary; // brun chaleureux
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: brown,
        elevation: 0.5,
        // leading: IconButton(
        //   icon: const Icon(Icons.grid_view_rounded),
        //   onPressed: () {
        //     Navigator.of(context).maybePop();
        //   },
        // ),
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
                    return _CartRow(item: it, accent: brown);
                  },
                ),
              ),
              _CartBottomBar(accent: brown),
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
              // Image du produit
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  item.assetImagePath,
                  width: 88,
                  height: 88,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              // Infos produit
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ligne titre + supprimer
                    Row(
                      children: [
                        // Rendre aussi le titre cliquable explicitement (optionnel)
                        Expanded(
                          child: GestureDetector(
                            onTap: _openDetails,
                            behavior: HitTestBehavior.opaque,
                            child: const SizedBox(), // occupe l'espace du titre
                          ),
                        ),
                        InkWell(
                          onTap: () => CartController.I.remove(key),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text('x', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                    // On remet le texte du titre en dessous pour l'affichage
                    // (alternative: garder le Text dans la Row et enlever le GestureDetector ci-dessus)
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    // Couleurs
                    if (item.color != null && item.color!.isNotEmpty)
                      Row(
                        children: [
                          const Text('Couleur   '),
                          if (swatch != null)
                            Container(
                              width: 36,
                              height: 12,
                              decoration: BoxDecoration(
                                color: swatch,
                                borderRadius: BorderRadius.circular(2),
                                border: Border.all(color: Colors.black12),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black12),
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
                       onPlus: () {
                        CartController.I.increment(key);
                        final item = CartController.I.items.firstWhere((e) => e.key == key);
                          quantite=item.qty;
                      },
                      onMinus: () {
                        CartController.I.decrement(key);
                        final item = CartController.I.items.firstWhere((e) => e.key == key);
                          quantite=item.qty;
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
    final border = BorderSide(color: accent, width: 1);
    final radius = BorderRadius.circular(4);
    return Row(
      children: [
        InkWell(
          onTap: onMinus,
          child: Container(
            
            decoration: BoxDecoration(border: Border(left: border, top: border, bottom: border), borderRadius: BorderRadius.only(topLeft: radius.topLeft, bottomLeft: radius.bottomLeft)),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Text('−', style: TextStyle(color: accent, fontSize: 16)),
          ),
        ),
        Container(
          decoration: BoxDecoration(color: accent, border: Border(top: border, bottom: border)),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text('$qty', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        ),
        InkWell(
          onTap: onPlus,
          child: Container(
            decoration: BoxDecoration(border: Border(right: border, top: border, bottom: border), borderRadius: BorderRadius.only(topRight: radius.topRight, bottomRight: radius.bottomRight)),
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

  /// Créer une commande et rediriger vers la page de paiement
Future<void> creerCommande(BuildContext context) async {
  final url = Uri.parse('http://192.168.0.108:8000/api/commandes');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer 2|UCI7B7Wxk6xe1j8uB2a96sZXak2PQvIiToHIh0EQ100c6016',
      },
      body: jsonEncode({"statut": "en_attente"}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final commandeId = data['commande']['id'];
      final montantTotal = data['commande']['montantTotal'];

      print("COMMANDE CRÉÉE : $commandeId - $montantTotal F");

      PaiementController().setCommandeId(commandeId);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentScreen(
            commandeId: commandeId,
            montant: montantTotal,
          ),
        ),
      );
    } else {
      print("Erreur : ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la création de la commande")),
      );
    }
  } catch (e) {
    print("Exception: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Erreur réseau")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final total = CartController.I.total;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0x11000000))),
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
                   // creerCommande(context);
                    //Navigator.pushNamed(context, AppRoutes.choixmodepayemnt);
                  //  Navigation.push(Context,MaterialPageRoute(builder: (context) => PaymentScreen(commandeId: commandeId, montant: montant),))
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




 int quantite = 1;
class PanierService {
  final String baseUrl = "http://192.168.0.108:8000/api";

  // Parse les produits
  List<Product> parseProduits(String responseBody) {
    final data = jsonDecode(responseBody);

    if (!data.containsKey('produits')) {
      throw Exception("Clé 'produits' absente dans la réponse API");
    }

    final List produits = data['produits'];

    return produits.map<Product>((json) {
      return Product(
        id: json['id'],
        name: json['name'],
        region: json['region'],
        type: json['type'],
        artisan: json['artisan'],
        price: json['price'],
        rating: json['rating'].toDouble(),
        likes: json['likes'],
        imageUrl: json['imageUrl'],
      );
    }).toList();
  }

  // Récupérer tous les produits
  Future<List<Product>> fetchProduits(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/produits"),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return parseProduits(response.body);
    } else {
      print("Erreur API fetch : ${response.body}");
      throw Exception("Impossible de charger les produits");
    }
  }

  // Ajouter un produit au panier
  Future<void> ajouterAuPanier(Product produit, int quantite) async {
    final response = await http.post(
      Uri.parse("$baseUrl/acheteur/panier/items"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer 3|gIwP7KlgOt8u4AedIbmN0CI55GdmH1kBVvCi2xVt3cc2c7b4',
      },
      body: jsonEncode({
        "produitId": produit.id,
        //"produitId": "55555555-5555-5555-5555-55555555555",
        "quantite": quantite,
      }),
    );

    if (response.statusCode == 201) {
      print("Produit ajouté au panier !");
    } else {
      print("Erreur ajout panier : ${response.body}");
    }
  }
}