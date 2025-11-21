import 'package:flutter/material.dart';

class PaiementController extends ChangeNotifier {
  // Singleton
  static final PaiementController _instance = PaiementController._internal();
  factory PaiementController() => _instance;
  PaiementController._internal();
  
  String? methode; // OrangeMoney, Wave, Mastercard
  Map<String, dynamic> infosPaiement = {}; // numeroMobile, numeroCarte etc.
  String? commandeId; // ID de la commande à payer

  // Définir la méthode de paiement
  void setMethode(String m) {
    methode = m;
    notifyListeners();
  }

  // Définir les infos de paiement
  void setInfos(Map<String, dynamic> infos) {
    infosPaiement = infos;
    notifyListeners();
  }

  // Définir la commande
  void setCommandeId(String id) {
    commandeId = id;
  }

  // Récupérer toutes les infos pour envoyer au backend
  Map<String, dynamic> getPaiementData() {
    return {
      'commandeId': commandeId,
      'methode': methode,
      'infosPaiement': infosPaiement
    };
  }
}
