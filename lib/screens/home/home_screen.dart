import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:malibots_challenge_eni/routes/app_routes.dart';
import 'package:malibots_challenge_eni/screens/home/vendeurpages/vendeur_dashboard.dart';
import 'package:malibots_challenge_eni/screens/musiques/musique_screen.dart';
import 'package:malibots_challenge_eni/screens/profile/profile_screnn_vendeur.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Color bogolan = const Color(0xFF7B3F00); // couleur bogolan
  int _currentIndex = 0;
  final pages = [
    HomeScreen(),
    HomeScreen(),
    HomeScreen(),
    HomeScreen(),
    ProfileScrennVendeur(),
    SellerDashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_currentIndex], // ✅ afficher la page sélectionnée

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if(index == 3) {
            Navigator.pushNamed(context, AppRoutes.panier);
          }
        },
        selectedItemColor: bogolan, // ta couleur
        unselectedItemColor: Colors.brown[300],
        type: BottomNavigationBarType.fixed, // ✅ Important si + de 3 items
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Boutique"),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: "Ajouter"),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Panier",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color bogolan = const Color(0xFF7B3F00); // couleur bogolan
  // final pages = [HomeScreen(),SellerDashboardScreen()];

  // Citations du jour
  final List<String> citations = [
    "Aaaah cette vie là, tu recules pour mieux sauter et puis tu glisses.",
    "Ahh les dogons sont foutus",
    "Hari kan moun chi kouna\nL’eau versée ne revient jamais dans le pot.",
    "Le mensonge donne des fleurs mais pas de fruits.",
    "Quand il n’y a pas d’ennemi à l’intérieur, l’ennemi extérieur ne peut rien.",
    "Un seul bracelet ne fait pas de bruit.",
  ];
  int citationIndex = 0;

  // Images du carrousel
  final List<String> carouselImages = [
    'assets/images/Acceuil/plats1.png',
    'assets/images/Acceuil/plats2.png',
    'assets/images/Acceuil/plats3.png',
  ];

  // Données des éléments "À la une"
  List<Map<String, dynamic>> aLaUne = [
    {"image": "assets/images/Acceuil/alaune1.png", "likes": 10, "liked": false},
    {"image": "assets/images/Acceuil/alaune2.jpg", "likes": 6, "liked": false},
    {"image": "assets/images/Acceuil/alaune3.jpg", "likes": 3, "liked": false},
  ];

  void refreshCitation() {
    setState(() {
      citationIndex = (citationIndex + 1) % citations.length;
    });
  }

  void toggleLike(int index) {
    setState(() {
      aLaUne[index]["liked"] = !aLaUne[index]["liked"];
      if (aLaUne[index]["liked"]) {
        aLaUne[index]["likes"]++;
      } else {
        aLaUne[index]["likes"]--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      drawer: Drawer(
        backgroundColor: bogolan,
        child: const Center(
          child: Text(
            "Menu latéral",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: bogolan, size: 30),
        title: Text(
          "Accueil",
          style: TextStyle(color: bogolan, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Iconsax.notification, color: bogolan),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carrousel d'images
            CarouselSlider(
              options: CarouselOptions(
                height: 200,
                autoPlay: true,
                viewportFraction: 1.0,
              ),
              items: carouselImages.map((img) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(img, fit: BoxFit.cover),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.catalogue,
                            arguments: 'Types',
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: bogolan,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Découvrir →",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Catégories
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Catégories",
                style: TextStyle(
                  color: bogolan,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategory(MdiIcons.tshirtV, "Tenues", () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.catalogue,
                      arguments: 'Tenues',
                    );
                  }),
                  _buildCategory(Icons.restaurant, "Plats", () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.catalogue,
                      arguments: 'Plats',
                    );
                  }),
                  _buildCategory(Iconsax.music, "Musique", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const MusiqueScreen(), // 👈 navigation vers Musique
                      ),
                    );
                  }),
                  _buildCategory(Iconsax.story, "Contes", () {}),
                  _buildCategory(Iconsax.shopping_bag, "Accessoires", () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.catalogue,
                      arguments: 'Accessoires',
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // À la une
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "À la une",
                style: TextStyle(
                  color: bogolan,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: aLaUne.length,
                itemBuilder: (context, index) {
                  var item = aLaUne[index];
                  return GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 150,
                      margin: const EdgeInsets.only(left: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.asset(
                                  item["image"],
                                  height: 120,
                                  width: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                bottom: 5,
                                right: 10,
                                child: GestureDetector(
                                  onTap: () => toggleLike(index),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Iconsax.heart5,
                                        color: item["liked"]
                                            ? Colors.red
                                            : Colors.white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        "${item["likes"]}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Caractéristiques",
                              style: TextStyle(
                                color: bogolan,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Espace culturel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Espace culturel",
                style: TextStyle(
                  color: bogolan,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: bogolan,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Iconsax.quote_down, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Citation du jour :",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            citations[citationIndex],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.refresh, color: Colors.white),
                      onPressed: refreshCitation,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Explorer la culture",
                        style: TextStyle(color: bogolan),
                      ),
                      Icon(Iconsax.arrow_right_3, color: bogolan),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),

      //Barre de navigation inférieure

      
    );
  }

  Widget _buildCategory(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: bogolan,
              radius: 25,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(color: bogolan, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
