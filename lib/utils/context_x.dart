// lib/utils/context_x.dart
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:malibots_challenge_eni/providers/favoris_store.dart';

/// Accès unique et centralisé au baseUrl de l’API depuis le context.
/// Évite les collisions d’extensions entre fichiers.
extension ContextApiX on BuildContext {
  String get apiBaseUrl => read<FavoritesStore>().baseUrl;
}