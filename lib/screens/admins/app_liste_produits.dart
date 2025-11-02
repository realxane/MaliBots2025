import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/models/product.dart';
import 'package:malibots_challenge_eni/screens/admins/app_approbation_produit.dart';

class ProduitsListePage extends StatefulWidget {
  const ProduitsListePage({super.key});

  @override
  State<ProduitsListePage> createState() => _ProduitsListePageState();
}

class _ProduitsListePageState extends State<ProduitsListePage> {
  final TextEditingController _searchController = TextEditingController();

  List<Product> products = [
    Product(
      id: '1',
      name: 'Chapeau',
      region: 'Bamako',
      type: 'Accessoire',
      artisan: 'Moussa Traoré',
      price: 20000,
      rating: 4.5,
      likes: 120,
      imageUrl: 'assets/images/produits/chapeau.jpeg',
    ),
    Product(
      id: '2',
      name: 'Bracelet',
      region: 'Kayes',
      type: 'Bijou',
      artisan: 'Fatoumata Diarra',
      price: 220000,
      rating: 4.8,
      likes: 310,
      imageUrl: 'assets/images/produits/bracelet.webp',
    ),
    Product(
      id: '3',
      name: 'Bazin',
      region: 'Ségou',
      type: 'Tissu',
      artisan: 'Amadou Keita',
      price: 60000,
      rating: 4.2,
      likes: 90,
      imageUrl: 'assets/images/produits/Bazin.png',
    ),
    Product(
      id: '4',
      name: 'Zamai',
      region: 'Mopti',
      type: 'Nourriture',
      artisan: 'Hawa Coulibaly',
      price: 1500,
      rating: 4.7,
      likes: 55,
      imageUrl: 'assets/images/produits/nourriture.png',
    ),
  ];

  void _openProductDetails(Product product) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ProductReviewPage(
        product: product,
        statusText: 'En attente du ${DateTime.now().toString().split(' ')[0]}',
      ),
    ),
  );
}


  String query = '';
  Set<String> selectedProductIds = {}; // 🟢 Multi-sélection

  @override
  Widget build(BuildContext context) {
    final filteredProducts = (products ?? [])
        .where((p) =>
            p.name.toLowerCase().contains(query.toLowerCase()) ||
            p.region.toLowerCase().contains(query.toLowerCase()) ||
            p.type.toLowerCase().contains(query.toLowerCase()) ||
            p.artisan.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Gestion des produits',
          style: TextStyle(color: Colors.white),
        ),
        actions: selectedProductIds.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      products.removeWhere(
                          (p) => selectedProductIds.contains(p.id));
                      selectedProductIds.clear();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Produits supprimés ✅')),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    // Ici tu peux gérer l'approbation de plusieurs produits
                    setState(() {
                      selectedProductIds.clear();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Produits approuvés ✅')),
                    );
                  },
                ),
              ]
            : null,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Champ de recherche
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => query = value),
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Liste des produits",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 🛒 Liste des produits
            Expanded(
              child: ListView.builder(
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  final isSelected = selectedProductIds.contains(product.id);

                  return GestureDetector(
                    onTap: () async {
                      // 🔁 Page de détails
                      _openProductDetails(product);
                    },
                    child:  Card(
  color: AppColors.primary,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  elevation: 4,
  margin: const EdgeInsets.symmetric(vertical: 6),
  child: ListTile(
    leading: CircleAvatar(
      radius: 25,
      backgroundColor: Colors.white,
      backgroundImage: AssetImage(product.imageUrl),
    ),
    title: Text(
      product.name,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    subtitle: Text(
      '${product.price} FCFA',
      style: const TextStyle(color: Colors.white70),
    ),
    trailing: PopupMenuButton<String>(
      icon: const Icon(Icons.menu, color: Colors.white),
      onSelected: (value) async {
        if (value == 'Voir') {
          // 🔹 Ouvrir la page détails
          _openProductDetails(product);
        } else if (value == 'Modifier') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Modifier ${product.name}')),
          );
        } else if (value == 'Supprimer') {
          setState(() {
            products.remove(product);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${product.name} supprimé')),
          );
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'Voir',
          child: Row(
            children: [
              Icon(Icons.visibility, color: AppColors.primary),
              SizedBox(width: 10),
              Text('Voir détails'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'Modifier',
          child: Row(
            children: [
              Icon(Icons.edit, color: AppColors.primary),
              SizedBox(width: 10),
              Text('Modifier'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'Supprimer',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 10),
              Text('Supprimer'),
            ],
          ),
        ),
      ],
    ),
    onTap: () async {
      // 🔹 Même logique que "Voir détails"
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductReviewPage(
            product: product,
            statusText:
                'En attente du ${DateTime.now().toString().split(' ')[0]}',
          ),
        ),
      );
    },
  ),
)
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
