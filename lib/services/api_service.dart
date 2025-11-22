import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // TODO: Настроить базовый URL (можно вынести в конфиг)
  static const String baseUrl = 'http://localhost:8010';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  // Получить сохраненный access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Сохранить токены
  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  // Очистить токены
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  // Регистрация пользователя
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Сохраняем токены
        await saveTokens(
          responseData['access_token'] as String,
          responseData['refresh_token'] as String,
        );
        return {
          'success': true,
          'access_token': responseData['access_token'],
          'refresh_token': responseData['refresh_token'],
        };
      } else {
        // Обработка ошибок
        final errorMessage = responseData['detail'] as String? ?? 
            'Ошибка регистрации';
        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } on http.ClientException {
      // Ошибка сети
      return {
        'success': false,
        'error': 'Ошибка подключения к серверу. Проверьте, что бэкенд запущен.',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Неизвестная ошибка: ${e.toString()}',
      };
    }
  }

  // Получить заголовки с авторизацией
  static Future<Map<String, String>> getAuthHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    final token = await getAccessToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
}

