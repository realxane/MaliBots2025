import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/models/product.dart';
import 'package:malibots_challenge_eni/routes/app_routes.dart';
import 'package:malibots_challenge_eni/screens/catalogue/app_panier.dart';
import 'package:malibots_challenge_eni/screens/catalogue/app_produit_detail.dart';
import 'package:malibots_challenge_eni/widgets/buttons/bouton_retour.dart';
import 'package:malibots_challenge_eni/widgets/product_card.dart';
import 'package:malibots_challenge_eni/widgets/text_fields/text_field_decor.dart';
import 'package:provider/provider.dart';
import 'catalog_controller.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});
  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  bool _argsApplied = false;

  final List<String> regionOptions = const [
    'Région','Bamako','Kayes','Koulikoro','Sikasso','Segou','Mopti','Tombouctou','Gao','Kidal',
  ];
  final List<String> typeOptions = const ['Types','Plats','Tenues','Accessoires'];
  final List<String> priceSortOptions = const ['Prix','Croissant','Décroissant'];

  String selectedRegion = 'Région';
  String selectedType = 'Types';
  String selectedArtisan = 'Artisan';
  String selectedPriceSort = 'Prix';
  String search = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsApplied) return;
    _argsApplied = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctrl = context.read<CatalogController>();
      ctrl.fetchFirstPage(); // premier chargement

      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String && typeOptions.contains(args)) {
        setState(() => selectedType = args);
      }
    });
  }

  List<Produit> _applyFilters(List<Produit> source) {
    var out = List<Produit>.from(source);

    if (search.trim().isNotEmpty) {
      final q = search.toLowerCase();
      out = out.where((p) =>
        p.nom.toLowerCase().contains(q) ||
        (p.artisan ?? '').toLowerCase().contains(q) ||
        (p.categorie ?? '').toLowerCase().contains(q) ||
        p.regionLabel.toLowerCase().contains(q)
      ).toList();
    }

    if (selectedRegion != 'Région') {
      out = out.where((p) => p.regionLabel == selectedRegion).toList();
    }
    if (selectedType != 'Types') {
      out = out.where((p) => p.typeUi == selectedType).toList();
    }
    if (selectedArtisan != 'Artisan') {
      out = out.where((p) => (p.artisan ?? '-') == selectedArtisan).toList();
    }
    if (selectedPriceSort == 'Croissant') {
      out.sort((a, b) => a.prixInt.compareTo(b.prixInt));
    } else if (selectedPriceSort == 'Décroissant') {
      out.sort((a, b) => b.prixInt.compareTo(a.prixInt));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<CatalogController>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final surface = isDark ? cs.surface : Colors.white;
    final onSurface = isDark ? cs.onSurface : AppColors.textSecondary;

    if (ctrl.loading && ctrl.items.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (ctrl.error != null && ctrl.items.isEmpty) {
      return Scaffold(body: Center(child: Text('Erreur: ${ctrl.error}')));
    }

    // options artisans calculées depuis les items chargés
    final artisanOptions = <String>{
      'Artisan',
      ...ctrl.items
          .map((p) => (p.artisan ?? '').trim())
          .where((a) => a.isNotEmpty)
    }.toList();

    final items = _applyFilters(ctrl.items);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0.5,
        leading: Navigator.canPop(context)
            ? fleche_retour(onPressed: () => Navigator.pushNamed(context, AppRoutes.accueil))
            : null,
        title: Text('Catalogue', style: TextStyle(color: onSurface, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<CatalogController>().refresh(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (sn) {
              if (sn.metrics.pixels >= sn.metrics.maxScrollExtent - 200) {
                context.read<CatalogController>().fetchNextPage();
              }
              return false;
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(children: [
                const SizedBox(height: 10),
                TextField(
                  onChanged: (v) => setState(() => search = v),
                  decoration: decor('Recherche').copyWith(prefixIcon: const Icon(Icons.search, color: Colors.grey)),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilter(context, regionOptions, selectedRegion, (v) => setState(() => selectedRegion = v!)),
                      const SizedBox(width: 8),
                      _buildFilter(context, typeOptions, selectedType, (v) => setState(() => selectedType = v!)),
                      const SizedBox(width: 8),
                      _buildFilter(context, artisanOptions, selectedArtisan, (v) => setState(() => selectedArtisan = v!)),
                      const SizedBox(width: 8),
                      _buildFilter(context, priceSortOptions, selectedPriceSort, (v) => setState(() => selectedPriceSort = v!)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    itemCount: items.length + (ctrl.canLoadMore ? 1 : 0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.75,
                    ),
                    itemBuilder: (_, i) {
                      if (i >= items.length) {
                        // cellule "spinner" de pagination
                        return const Center(child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ));
                      }
                      final p = items[i];
                      return ProductCard(
                        product: p,
                        onAdd: () {
                          CartController.I.addItem(
                            productId: p.id,
                            name: p.nom,
                            color: null,
                            price: p.prixInt,
                            assetImagePath: p.imageBest,
                            qty: 1,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${p.nom} ajouté au panier'),
                              action: SnackBarAction(label: 'Voir', onPressed: () => Navigator.pushNamed(context, AppRoutes.panier)),
                            ),
                          );
                        },
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: p)));
                        },
                      );
                    },
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilter(BuildContext context, List<String> items, String value, void Function(String?) onChanged) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark ? cs.surfaceVariant : AppColors.textSecondary;
    final fg = isDark ? cs.onSurface : Colors.white;
    final ddBg = isDark ? cs.surface : AppColors.textSecondary;
    final iconColor = fg;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: Icon(Icons.keyboard_arrow_down, color: iconColor),
          dropdownColor: ddBg,
          style: TextStyle(color: fg, fontSize: 14),
          onChanged: onChanged,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: fg)))).toList(),
        ),
      ),
    );
  }
}