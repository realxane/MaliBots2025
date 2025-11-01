class Product {
  final String id;
  final String name;
  final String region;     // Bamako, Kayes, Koulikoro, Sikasso, Segou, Mopti, Tombouctou, Gao, Kidal
  final String type;       // Nourriture, Habits, Accessoires
  final String artisan;    // Nom de l’artisan
  final int price;         // en FCFA
  final double rating;     // 0..5
  final int likes;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.region,
    required this.type,
    required this.artisan,
    required this.price,
    required this.rating,
    required this.likes,
    required this.imageUrl,
  });
}