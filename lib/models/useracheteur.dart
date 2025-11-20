class Useracheteur {
  final String? id;
  final String nom;
  final String? email;
  final String? telephone;
  final String region;
  

  Useracheteur({

    this.id,
    required this.nom,
    this.email,
    this.telephone,
    required this.region,
  });

  // JSON → MODEL
  factory Useracheteur.fromJson(Map<String, dynamic> json) {
    return Useracheteur(
      id: json['id']?.toString(),

      nom: json['nom'] ?? '',
      email: json['email'],
      telephone: json['telephone'],
      region: json['region'] ?? '',
    );
  }

  // MODEL → JSON (si tu veux renvoyer à l’API)
  Map<String, dynamic> toJson() {
    return {
      "nom": nom,
      "email": email,
      "region": region,
      "telephone": telephone,
     
    };
  }
}
