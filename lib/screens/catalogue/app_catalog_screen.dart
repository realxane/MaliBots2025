import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/data/list_product.dart';
import 'package:malibots_challenge_eni/models/product.dart';
import 'package:malibots_challenge_eni/routes/app_routes.dart';
import 'package:malibots_challenge_eni/screens/catalogue/app_panier.dart';
import 'package:malibots_challenge_eni/screens/catalogue/app_produit_detail.dart';
import 'package:malibots_challenge_eni/widgets/buttons/bouton_retour.dart';
import 'package:malibots_challenge_eni/widgets/product_card.dart';
import 'package:malibots_challenge_eni/widgets/text_fields/text_field_decor.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {

  bool _argsApplied = false; // pour ne le faire qu’une fois

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsApplied) return;
    _argsApplied = true;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is String && typeOptions.contains(args)) {
      selectedType = args; // <- on applique au filtre existant
      setState(() {});     // <- on déclenche le rebuild
    }
  }

  // Options de filtres
  final List<String> regionOptions = const [
    'Région',
    'Bamako',
    'Kayes',
    'Koulikoro',
    'Sikasso',
    'Segou',
    'Mopti',
    'Tombouctou',
    'Gao',
    'Kidal',
  ];

  final List<String> typeOptions = const [
    'Types',
    'Plats',
    'Tenues',
    'Accessoires',
  ];

  final List<String> priceSortOptions = const [
    'Prix',
    'Croissant',
    'Décroissant',
  ];

  // Valeurs sélectionnées
  String selectedRegion = 'Région';
  String selectedType = 'Types';
  String selectedArtisan = 'Artisan';
  String selectedPriceSort = 'Prix';
  String search = '';

  // Construire dynamiquement la liste des artisans à partir des données
  List<String> get artisanOptions {
    final names = <String>{'Artisan'};
    for (final p in kProducts) {
      names.add(p.artisan);
    }
    return names.toList();
  }

  List<Product> get filtered {
    List<Product> out = List.from(kProducts);

    if (search.trim().isNotEmpty) {
      final q = search.toLowerCase();
      out = out.where((p) =>
        p.name.toLowerCase().contains(q) ||
        p.artisan.toLowerCase().contains(q) ||
        p.type.toLowerCase().contains(q) ||
        p.region.toLowerCase().contains(q)
      ).toList();
    }

    if (selectedRegion != 'Région') {
      out = out.where((p) => p.region == selectedRegion).toList();
    }
    if (selectedType != 'Types') {
      out = out.where((p) => p.type == selectedType).toList();
    }
    if (selectedArtisan != 'Artisan') {
      out = out.where((p) => p.artisan == selectedArtisan).toList();
    }
    if (selectedPriceSort == 'Croissant') {
      out.sort((a, b) => a.price.compareTo(b.price));
    } else if (selectedPriceSort == 'Décroissant') {
      out.sort((a, b) => b.price.compareTo(a.price));
    }

    return out;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: IconButton(
        //   icon: const Icon(Icons.apps, color: AppColors.textSecondary),
        //   onPressed: () {
        //     Navigator.pushNamed(context, AppRoutes.accueil);
        //   },
        // ),
        leading: Navigator.canPop(context)
            ? fleche_retour(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.accueil);
                },
              )
            : null,
        title: const Text('Catalogue',
            style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
        // actions: [
        //   Stack(
        //     alignment: Alignment.topRight,
        //     children: [
        //       IconButton(
        //         icon: const Icon(Icons.notifications_none, color: AppColors.textSecondary, size: 26),
        //         onPressed: () {},
        //       ),
        //       Container(
        //         margin: const EdgeInsets.only(top: 14, right: 14),
        //         width: 8,
        //         height: 8,
        //         decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
        //       ),
        //     ],
        //   ),
        // ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Barre de recherche
              TextField(
                onChanged: (v) => setState(() => search = v),
                decoration: decor('Recherche').copyWith(
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                )
              ),
              const SizedBox(height: 14),
              // Filtres
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilter(regionOptions, selectedRegion, (v) => setState(() => selectedRegion = v!)),
                    const SizedBox(width: 8),
                    _buildFilter(typeOptions, selectedType, (v) => setState(() => selectedType = v!)),
                    const SizedBox(width: 8),
                    _buildFilter(artisanOptions, selectedArtisan, (v) => setState(() => selectedArtisan = v!)),
                    const SizedBox(width: 8),
                    _buildFilter(priceSortOptions, selectedPriceSort, (v) => setState(() => selectedPriceSort = v!)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Grille produits
              Expanded(
                child: GridView.builder(
                  itemCount: filtered.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (_, i) {
                    final p = filtered[i];
                    return ProductCard(
                      product: p,
                      onAdd: () {
                        // Ajout au panier
                        CartController.I.addItem(
                          productId: p.id,
                          name: p.name,
                          color: null, // pas de choix couleur ici
                          price: p.price,
                          assetImagePath: p.imageUrl, // marche pour asset; si URL, voir note bonus
                          qty: 1,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${p.name} ajouté au panier'),
                            action: SnackBarAction(
                              label: 'Voir',
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.panier);
                              },
                            ),
                          ),
                        );
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailPage(product: p),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  

  // Bouton "chip" + Dropdown
  Widget _buildFilter(
    List<String> items,
    String value,
    void Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.textSecondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          dropdownColor: AppColors.textSecondary,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          onChanged: onChanged,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        ),
      ),
    );
  }
}