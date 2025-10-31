// lib/models/product.dart
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final List<String> images; // paths from gallery (local file paths)
  final String region;
  final String category;
  final String color;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.images,
    required this.region,
    required this.category,
    required this.color,
  });

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? stock,
    List<String>? images,
    String? region,
    String? category,
    String? color,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      images: images ?? this.images,
      region: region ?? this.region,
      category: category ?? this.category,
      color: color ?? this.color,
    );
  }
}
