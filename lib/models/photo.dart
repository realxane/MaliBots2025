import 'package:equatable/equatable.dart';

// Modèle pour une seule image d'une publication Photo
class PhotoImage extends Equatable {
  final String id;
  final String photoId;
  final String filename;
  final String
      url; // L'URL complète pour l'affichage (ex: http://192.168.1.35:8000/storage/...)
  final String mime;
  final int order;

  const PhotoImage({
    required this.id,
    required this.photoId,
    required this.filename,
    required this.url,
    required this.mime,
    required this.order,
  });

  factory PhotoImage.fromJson(Map<String, dynamic> json) {
    return PhotoImage(
      id: json['id'].toString(),
      photoId: json['photoId']?.toString() ?? json['photo_id'].toString(),
      filename: json['filename'] as String,
      url: json['url'] as String,
      mime: json['mime'] as String,
      order: (json['order'] as num).toInt(),
    );
  }

  @override
  List<Object?> get props => [id, photoId, url, order];
}

// Modèle pour une publication de Photo
class Photo extends Equatable {
  final String id;
  final String titre;
  final String description;
  final String? regionId;
  final String? publieParAdminId;
  // La relation 'images' est une liste d'objets PhotoImage
  final List<PhotoImage> images;

  const Photo({
    required this.id,
    required this.titre,
    required this.description,
    this.regionId,
    this.publieParAdminId,
    required this.images,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    final List<PhotoImage> imageList =
        (json['images'] as List<dynamic>?)
                ?.map(
                  (imgJson) =>
                      PhotoImage.fromJson(imgJson as Map<String, dynamic>),
                )
                .toList() ??
            [];

    return Photo(
      id: json['id'].toString(),
      titre: json['titre'] as String,
      description: json['description'] as String,
      regionId: json['regionId']?.toString() ?? json['region_id']?.toString(),
      publieParAdminId:
          json['publieParAdminId']?.toString() ?? json['publie_par_admin_id']?.toString(),
      images: imageList,
    );
  }

  @override
  List<Object?> get props => [id, titre, images];
}