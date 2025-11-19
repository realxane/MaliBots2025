import 'dart:convert';
import 'package:http/http.dart' as http;
import './api_client.dart';

abstract class ImageUploader {
  Future<String> uploadFile(String filePath);
  Future<List<String>> uploadAll(List<String> filePaths) async {
    final out = <String>[];
    for (final p in filePaths) {
      out.add(await uploadFile(p));
    }
    return out;
  }
}

// Suppose un endpoint POST /api/uploads qui renvoie { "url": "https://..." }
class LaravelImageUploader implements ImageUploader {
  final ApiClient _api;
  LaravelImageUploader(this._api);

  @override
  Future<String> uploadFile(String filePath) async {
    final uri = Uri.parse('${_api.baseUrl}/uploads');
    final req = http.MultipartRequest('POST', uri);
    req.headers.addAll(await _api.multipartHeaders());
    req.files.add(await http.MultipartFile.fromPath('file', filePath));
    final res = await req.send();

    final body = await res.stream.bytesToString();
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final j = jsonDecode(body) as Map<String, dynamic>;
      final url = j['url']?.toString();
      if (url == null || url.isEmpty) {
        throw ApiException(res.statusCode, 'Réponse upload invalide');
      }
      return url;
    }
    throw ApiException(res.statusCode, 'Upload échoué: $body');
  }
  
  @override
  Future<List<String>> uploadAll(List<String> filePaths) async {
    final out = <String>[];
    for (final p in filePaths) {
      out.add(await uploadFile(p));
    }
    return out;
  }
}