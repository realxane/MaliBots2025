import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/models/product.dart';
import 'package:malibots_challenge_eni/routes/app_routes.dart';
import 'package:malibots_challenge_eni/screens/admins/app_approbation_produit.dart';
import 'package:malibots_challenge_eni/screens/admins/app_liste_users.dart';
import 'package:malibots_challenge_eni/screens/admins/app_liste_vendeurs.dart';

// Couleur thème locale
final Color _brown = AppColors.textSecondary;

// Types d'activités visibles dans le dashboard
enum ActivityType { productAdded, postDeleted, report }

// Modèle d'activité (générique)
class Activity {
  final ActivityType type;
  final String title;
  final String subtitle; // ex: "En attente..." ou le nom d'auteur/declarant
  final IconData icon;
  final Product? product; // utilisé si type == productAdded

  const Activity({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.product,
  });
}

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _index = 0;

  // Exemple de produit "robe bazin" venant d'une publication vendeur
  final Product _robeBazin = Product(
    id: 'p1',
    name: 'Boubou bazin',
    region: 'Sikasso',
    type: 'Tenues',
    artisan: 'Moussa',
    price: 18000,
    rating: 4.8,
    likes: 31,
    imageUrl: 'assets/images/produits/Bazin.png',
  );

  List<Activity> get _activities => [
        Activity(
          type: ActivityType.productAdded,
          title: 'Produit ajouté ${_robeBazin.name}',
          subtitle: 'En attente aujourd’hui 9h10',
          icon: Icons.check_circle,
          product: _robeBazin,
        ),
        Activity(
          type: ActivityType.productAdded,
          title: 'Produit ajouté Boubou bogolan',
          subtitle: 'En attente hier 17h20',
          icon: Icons.new_releases_outlined,
          product: _robeBazin.copyWith(id: 'p2', name: 'Boubou bogolan'),
        ),
        Activity(
          type: ActivityType.productAdded,
          title: 'Produit ajouté Sandales cuir',
          subtitle: 'En attente 30/10 11h02',
          icon: Icons.shopping_bag_outlined,
          product: _robeBazin.copyWith(id: 'p3', name: 'Sandales cuir'),
        ),
        // Activités non-produit que tu avais
        Activity(
          type: ActivityType.postDeleted,
          title: 'Publication supprimée',
          subtitle: 'Adama',
          icon: Icons.delete_outline,
        ),
        Activity(
          type: ActivityType.report,
          title: 'Signalement',
          subtitle: 'Ousmane',
          icon: Icons.report_outlined,
        ),
      ];

      final List<Widget> _pages = const [
        UserListPage(),
        VendeursListePage(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('SuperAdmin'),
        backgroundColor: _brown,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          _chipHeader(),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _statCard('Users', '120', Icons.person)),
            const SizedBox(width: 12),
            Expanded(child: _statCard('Vendeurs', '63', Icons.store)),
          ]),
          const SizedBox(height: 20),
          _sectionTitle('Statistiques'),
          const SizedBox(height: 8),
          _salesChartByMonth(const {
            'Jan': 40,
            'Fév': 85,
            'Mar': 60,
            'Avr': 100,
            'Mai': 55,
            'Juin': 90,
          }),
          const SizedBox(height: 20),
          _sectionTitle('Activités récentes'),
          const SizedBox(height: 8),

          // Liste des activités hétérogènes
          for (final a in _activities) _activityItem(a),
        ]),
      ),
       
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) {
        setState(() => _index = i);
        if(i==0){Navigator.pushNamed(context, AppRoutes.admin_dash);}
        if(i==1){Navigator.pushNamed(context, AppRoutes.adminListeUsers);}
        if(i==2){Navigator.pushNamed(context, AppRoutes.adminListeVendeurs);}
        if(i==3){Navigator.pushNamed(context, AppRoutes.adminListeProduits);}
        if(i==4){Navigator.pushNamed(context, AppRoutes.adminListeCultures);}
        if(i==5){Navigator.pushNamed(context, AppRoutes.adminprofile);}

        },
        // showSelectedLabels: true,
        // showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: _brown,
        unselectedItemColor: _brown.withOpacity(.5),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.supervised_user_circle), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.sell_rounded), label: 'Vendeurs'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Produits'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Contenus'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _chipHeader() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _brown.withOpacity(.15)),
        ),
        child: Row(children: [
          Icon(Icons.dashboard, color: _brown, size: 18),
          const SizedBox(width: 8),
          Text(
            'Dashboard administrateur',
            style: TextStyle(color: _brown, fontWeight: FontWeight.w600),
          ),
        ]),
      );

  Widget _statCard(String title, String value, IconData icon) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _brown.withOpacity(.15)),
          boxShadow: [BoxShadow(color: _brown.withOpacity(.06), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: _brown),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: _brown)),
          Text(title, style: TextStyle(color: _brown.withOpacity(.8))),
        ]),
      );

  Widget _sectionTitle(String t) =>
      Text(t, style: TextStyle(fontWeight: FontWeight.w700, color: _brown));

  Widget _salesChartByMonth(Map<String, int> byMonth) {
    final entries = byMonth.entries.toList();
    final maxVal = entries.fold<int>(0, (m, e) => e.value > m ? e.value : m);
    const maxBarHeight = 110.0;

    return Container(
      height: 170,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _brown.withOpacity(.15)),
      ),
      child: Column(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: entries.map((e) {
                  final h = maxVal == 0 ? 0.0 : (e.value / maxVal) * maxBarHeight;
                  return Container(
                    width: 22,
                    height: h,
                    decoration: BoxDecoration(
                      color: _brown,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: entries
                .map((e) => SizedBox(
                      width: 22,
                      child: Text(
                        e.key,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: _brown.withOpacity(.8), fontSize: 11),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // Item d'activité générique
  Widget _activityItem(Activity a) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: _brown.withOpacity(.15)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _openActivity(a),
            child: ListTile(
              leading: Icon(a.icon, color: _brown),
              title: Text(a.title),
              subtitle: Text(a.subtitle),
              dense: true,
            ),
          ),
        ),
      );

  void _openActivity(Activity a) {
    switch (a.type) {
      case ActivityType.productAdded:
        final product = a.product!;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductReviewPage(
              product: product,
              statusText: a.subtitle,
            ),
          ),
        );
        break;
      case ActivityType.postDeleted:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const _DummyPage(title: 'Publication')),
        );
        break;
      case ActivityType.report:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const _DummyPage(title: 'Signalement')),
        );
        break;
    }
  }
}

// Page descriptive du produit avec actions Rejeter / Approuver


  

// Page placeholder pour "Publication" et "Signalement"
class _DummyPage extends StatelessWidget {
  final String title;
  const _DummyPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _brown,
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: Center(
        child: Text(
          'Page $title',
          style: TextStyle(color: _brown, fontSize: 18),
        ),
      ),
    );
  }
}

// Extension utilitaire pour dupliquer un produit avec quelques champs modifiés
extension on Product {
  Product copyWith({
    String? id,
    String? name,
    String? region,
    String? type,
    String? artisan,
    int? price,
    double? rating,
    int? likes,
    String? imageUrl,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      region: region ?? this.region,
      type: type ?? this.type,
      artisan: artisan ?? this.artisan,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      likes: likes ?? this.likes,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}