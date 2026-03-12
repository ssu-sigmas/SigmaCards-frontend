import 'dart:convert';
import 'package:http/http.dart' as http;

class UnsplashService {
  static const String _accessKey = 'YOUR_UNSPLASH_ACCESS_KEY';
  static const String _baseUrl = 'https://api.unsplash.com';

  // Вернёт URL изображения или null если ключ не настроен / ошибка сети
  static Future<String?> fetchPhotoUrl(String query) async {
    if (_accessKey.startsWith('YOUR_')) return null;
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/photos/random'
          '?query=${Uri.encodeComponent(query)}'
          '&orientation=landscape'
          '&client_id=$_accessKey',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final urls = data['urls'] as Map<String, dynamic>;
        return urls['small'] as String?;
      }
    } catch (_) {}
    return null;
  }

  // Скачать байты изображения по URL
  static Future<List<int>?> downloadImageBytes(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) return response.bodyBytes;
    } catch (_) {}
    return null;
  }
}
