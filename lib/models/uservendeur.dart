class Uservendeur {
  final String? id;
  final String nom;
  final String? email;
  final String? telephone;
  final String region;
  final String telephonePro;
  final String savoirFaire;

  Uservendeur({

    this.id,
    required this.nom,
    this.email,
    this.telephone,
    required this.region,
    required this.telephonePro,
    required this.savoirFaire,
  });

  // JSON → MODEL
  factory Uservendeur.fromJson(Map<String, dynamic> json) {
    return Uservendeur(
      id: json['id']?.toString(),

      nom: json['nom'] ?? '',
      email: json['email'],
      telephone: json['telephone'],
      region: json['region'] ?? '',
      telephonePro: json['telephone_pro'] ?? '',
      savoirFaire: json['descrit_ton_savoir_faire'] ?? '',
    );
  }

  // MODEL → JSON (si tu veux renvoyer à l’API)
  Map<String, dynamic> toJson() {
    return {
      "nom": nom,
      "email": email,
      "region": region,
      "telephone": telephone,
      "telephone_pro": telephonePro,
      "descrit_ton_savoir_faire": savoirFaire,
    };
  }
}
