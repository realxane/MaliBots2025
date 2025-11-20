class Uservendeur {
  final String? id;
  final String nom;
  final String? email;
  final String? telephone;
  final String region;          // on garde String
  final String telephonePro;
  final String savoirFaire;

  Uservendeur({
    this.id,
    required this.nom,
    this.email,
    this.telephone,
    required this.region,
    this.telephonePro = '',
    this.savoirFaire = '',
  });

  factory Uservendeur.fromJson(Map<String, dynamic> json) {
    // region peut être soit une string, soit un objet { id, nom, ... }
    final dynamic regionField = json['region'];
    String parsedRegion = '';
    if (regionField is Map) {
      parsedRegion = regionField['nom']?.toString() 
                     ?? regionField['name']?.toString() 
                     ?? regionField['id']?.toString() 
                     ?? '';
    } else {
      parsedRegion = regionField?.toString() 
                     ?? json['regionId']?.toString() 
                     ?? '';
    }

    return Uservendeur(
      id: json['id']?.toString(),
      nom: json['nom']?.toString() ?? '',
      email: json['email']?.toString(),
      telephone: json['telephone']?.toString(),
      region: parsedRegion,
      telephonePro: json['telephone_pro']?.toString() ?? '',
      savoirFaire: json['descrit_ton_savoir_faire']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "nom": nom,
      "email": email,
      "region": region, // côté envoi, on garde une string
      "telephone": telephone,
      "telephone_pro": telephonePro,
      "descrit_ton_savoir_faire": savoirFaire,
    };
  }
}