import '../config/app_config.dart';

String uiToBackendCategorie(String ui) {
  switch (ui) {
    case 'Plats': return 'Plat';
    case 'Tenue':
    case 'Tenues': return 'Habit';
    case 'Accessoire':
    case 'Accessoires':
    case 'Chapeau':
    case 'Robe':
    case 'Bijoux':
      return 'Accessoire';
    default:
      return 'Accessoire';
  }
}

String? uiRegionLabelToId(String label) {
  return AppConfig.regionIdByLabel[label];
}