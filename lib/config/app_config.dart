class AppConfig {
  // static const String apiBaseUrl = 'http://10.0.2.2:8000/api';
  static const String apiBaseUrl = 'http://192.168.1.103:8000/api';

  // À adapter: mets les vrais IDs (UUID/keys) venant de ta table regions
  static const Map<String, String> regionIdByLabel = {
    'Bamako': '019a8047-4d36-7321-ba61-8697d9d3e5c8',
    // 'Sikasso': 'uuid-sikasso',
    // 'Ségou': 'uuid-segou',
    // 'Kayes': 'uuid-kayes',
    // 'Tombouctou': 'uuid-tombouctou',
  };
} 