import 'package:equatable/equatable.dart';

class Region extends Equatable {
  final String id;
  final String nom;

  const Region({required this.id, required this.nom});

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'].toString(),
      nom: json['nom'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nom': nom};
  }

  @override
  List<Object?> get props => [id, nom];
}