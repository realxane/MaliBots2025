// lib/screens/seller_dashboard.dart
import 'dart:io';
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

  Widget _statBar(String label, int value, Color color, double ratio) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 160 * ratio,
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

            // ✅ Expanded to avoid overflow
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

                  // ✅ Colors dropdown inside Row with wrap protection
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
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(
                                    c,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
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
    final titleStyle = TextStyle(
      color: bogolan,
      fontWeight: FontWeight.bold,
      fontSize: 18,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
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
            // Stats
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
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
                        onPressed: () {},
                        icon: Icon(Icons.refresh, color: bogolan),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
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

            // ✅ Scroll flexible
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (_, i) => _productCard(products[i]),
              ),
            ),

            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _openAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: bogolan,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Ajouter un produit',
                  style: AppTextStyles.button,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
