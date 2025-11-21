// lib/utils/image_urls.dart
import 'package:flutter/foundation.dart';

// RENSEIGNE ICI l’IP de ton PC + le port Laravel (artisan serve)
const String kDevHost = '192.168.1.103';
const int kDevPort = 8000;
const String kDevScheme = 'http'; // 'http' en dev, 'https' si reverse-proxy
const String kDevBaseOrigin = '$kDevScheme://$kDevHost:$kDevPort';

bool _isHttp(String s) => s.startsWith('http://') || s.startsWith('https://');

String normalizeImageRef(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return s;

  // 1) URL relative retournée par Laravel: "/storage/…"
  if (s.startsWith('/storage/')) {
    return '$kDevBaseOrigin$s';
  }
  // Parfois côté serveur on renvoie "storage/…" (sans slash)
  if (s.startsWith('storage/')) {
    return '$kDevBaseOrigin/$s';
  }

  // 2) URL absolue http(s)
  if (_isHttp(s)) {
    Uri? u;
    try { u = Uri.parse(s); } catch (_) {}
    if (u == null) return s;

    // Hosts à forcer vers l’IP du PC
    const localHosts = {'localhost', '127.0.0.1', '::1', '10.0.2.2', '10.0.3.2'};
    final isLocalLike = localHosts.contains(u.host);

    // a) si host "local" -> remap vers IP:port
    if (isLocalLike) {
      return u.replace(scheme: kDevScheme, host: kDevHost, port: kDevPort).toString();
    }

    // b) si déjà sur l’IP du PC mais SANS port (ex: http://192.168.1.103/storage/…)
    final missingPort = (u.hasPort == false || (u.port == 0));
    final isDevIp = (u.host == kDevHost);
    if (isDevIp && missingPort) {
      return u.replace(port: kDevPort, scheme: kDevScheme).toString();
    }

    // c) tout le reste: on garde tel quel
    return u.toString();
  }

  // 3) Autres cas: on laisse (fichiers locaux, assets, data:…)
  return s;
}