import 'package:flutter/material.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("À propos de l'application"),
        centerTitle: true,
        backgroundColor: Colors.brown.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                "assets/images/icon3.png", 
                height: 120,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "🇲🇱 À propos de MaliBots Culture",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Bienvenue dans MaliBots Culture, une application 100 % dédiée à la découverte, la valorisation et la transmission de la culture malienne. "
              "Notre mission est simple : promouvoir le savoir-faire traditionnel du Mali et offrir une plateforme moderne où artisans, créateurs et passionnés peuvent se rencontrer, vendre et acheter des produits authentiques.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),
            const Text(
              "🛍️ Une vitrine du patrimoine malien",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown),
            ),
            const SizedBox(height: 10),
            const Text(
              "MaliBots Culture n’est pas seulement une application de vente, c’est une fenêtre ouverte sur l’identité malienne. "
              "Tu y trouveras une grande variété d’articles issus de nos traditions :\n\n"
              "• 👕 Vêtements traditionnels : bazins, boubous, pagnes, bogolans...\n"
              "• 💍 Accessoires artisanaux : bijoux, chapeaux, sandales, perles, objets décoratifs.\n"
              "• 🍛 Produits alimentaires : couscous local, farines, épices, beurres, miel, mets maliens.\n"
              "• 🎵 Musiques traditionnelles : balafon, djembé, ngoni, chants et rythmes du pays.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),
            const Text(
              "🤝 Un pont entre tradition et modernité",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown),
            ),
            const SizedBox(height: 10),
            const Text(
              "Notre objectif est d’unir l’héritage culturel et les technologies d’aujourd’hui. "
              "Grâce à MaliBots Culture, tu peux acheter ou vendre facilement des produits traditionnels, "
              "soutenir directement les artisans locaux et partager ta passion avec une communauté engagée.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),
            const Text(
              "🌍 Un espace pour tous les amoureux du Mali",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown),
            ),
            const SizedBox(height: 10),
            const Text(
              "Que tu sois au Mali ou à l’étranger, MaliBots Culture te permet de rester connecté à tes racines. "
              "Elle t’offre un espace d’échange et de valorisation où chaque achat devient un geste pour la culture.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),
            const Text(
              "❤️ Notre engagement",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown),
            ),
            const SizedBox(height: 10),
            const Text(
              "Nous nous engageons à promouvoir l’artisanat local, offrir une plateforme simple et sécurisée, "
              "et mettre en avant la richesse culturelle de toutes les régions du Mali. "
              "Nous inspirons les jeunes générations à être fières de leurs origines et à perpétuer nos traditions.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),
            const Text(
              "🎯 Notre vision",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown),
            ),
            const SizedBox(height: 10),
            const Text(
              "Faire de MaliBots Culture la référence numérique du patrimoine malien, "
              "un lieu où la tradition rencontre l’innovation et où chaque utilisateur devient acteur de la préservation de notre culture.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),
            const Text(
              "🙏 Merci",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown),
            ),
            const SizedBox(height: 10),
            const Text(
              "Merci d’utiliser MaliBots Culture. En rejoignant cette aventure, tu contribues à faire vivre la beauté, la diversité et la fierté du Mali à travers ses arts, ses sons et ses saveurs.\n\n"
              "✨ MaliBots Culture — La tradition au bout des doigts.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                "© 2025 MaliBots Culture. Tous droits réservés.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
