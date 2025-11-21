// Fichier: models/region.dart

import 'package:equatable/equatable.dart';

class Region extends Equatable {
  final String id;
  final String nom;

  const Region({required this.id, required this.nom});

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(id: json['id'] as String, nom: json['nom'] as String);
  }

  // Optionnel : méthode pour convertir l'objet en JSON si vous deviez l'envoyer
  Map<String, dynamic> toJson() {
    return {'id': id, 'nom': nom};
  }

  @override
  List<Object?> get props => [id, nom];
}
