import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8010';
  static const String _v1 = '/api/v1';
  static const _uuid = Uuid();

  // Persistent client — dart:io HttpClient negotiates HTTP/2 via ALPN on TLS
  static final http.Client _client = IOClient(
    HttpClient()..connectionTimeout = const Duration(seconds: 15),
  );

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  
  // Флаг для предотвращения рекурсивного refresh
  static bool _isRefreshing = false;

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

  // Получить сохраненный refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // Сохранить userId
  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  // Получить сохраненный userId
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Очистить токены и userId
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
  }

  // Регистрация пользователя
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl$_v1/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Idempotency-Key': _uuid.v4(),
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
        
        // Получаем информацию о пользователе для сохранения userId
        // Используем skipRefresh, так как токен только что получен
        final userResult = await getCurrentUser(skipRefresh: true);
        if (userResult['success'] == true) {
          final user = userResult['user'] as User;
          await saveUserId(user.id);
        }
        
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

  // Вход пользователя
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl$_v1/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        // Сохраняем токены
        await saveTokens(
          responseData['access_token'] as String,
          responseData['refresh_token'] as String,
        );
        
        // Получаем информацию о пользователе для сохранения userId
        // Используем skipRefresh, так как токен только что получен
        final userResult = await getCurrentUser(skipRefresh: true);
        if (userResult['success'] == true) {
          final user = userResult['user'] as User;
          await saveUserId(user.id);
        }
        
        return {
          'success': true,
          'access_token': responseData['access_token'],
          'refresh_token': responseData['refresh_token'],
        };
      } else {
        // Обработка ошибок
        final errorMessage = responseData['detail'] as String? ?? 
            'Ошибка входа';
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

  // Обновить access token используя refresh token
  static Future<Map<String, dynamic>> refreshToken() async {
    if (_isRefreshing) {
      // Если уже идет refresh, ждем
      await Future.delayed(const Duration(milliseconds: 500));
      final token = await getAccessToken();
      if (token != null) {
        return {'success': true};
      }
    }

    _isRefreshing = true;
    try {
      final refreshTokenValue = await getRefreshToken();
      if (refreshTokenValue == null) {
        return {
          'success': false,
          'error': 'Refresh token не найден',
        };
      }

      final response = await _client.post(
        Uri.parse('$baseUrl$_v1/auth/refresh?refresh_token=${Uri.encodeComponent(refreshTokenValue)}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        // Сохраняем новые токены
        await saveTokens(
          responseData['access_token'] as String,
          responseData['refresh_token'] as String,
        );
        _isRefreshing = false;
        return {
          'success': true,
          'access_token': responseData['access_token'],
          'refresh_token': responseData['refresh_token'],
        };
      } else {
        // Refresh token невалиден, очищаем все
        await clearTokens();
        _isRefreshing = false;
        final errorMessage = responseData['detail'] as String? ?? 
            'Ошибка обновления токена';
        return {
          'success': false,
          'error': errorMessage,
          'requiresLogin': true,
        };
      }
    } on http.ClientException {
      _isRefreshing = false;
      return {
        'success': false,
        'error': 'Ошибка подключения к серверу',
      };
    } catch (e) {
      _isRefreshing = false;
      return {
        'success': false,
        'error': 'Неизвестная ошибка: ${e.toString()}',
      };
    }
  }

  // Получить информацию о текущем пользователе
  static Future<Map<String, dynamic>> getCurrentUser({bool skipRefresh = false}) async {
    try {
      // Если skipRefresh = true, используем прямой запрос без автоматического refresh
      // Это нужно сразу после login/register, когда токен точно валиден
      http.Response response;
      
      if (skipRefresh) {
        final headers = await getAuthHeaders();
        response = await _client.get(
          Uri.parse('$baseUrl$_v1/users/me'),
          headers: headers,
        );
      } else {
        final result = await _makeAuthenticatedRequest(
          method: 'GET',
          endpoint: '/users/me',
        );
        
        if (result['success'] == true) {
          final userData = result['data'] as Map<String, dynamic>;
          final user = User.fromJson(userData);
          
          // Сохраняем userId
          await saveUserId(user.id);
          
          return {
            'success': true,
            'user': user,
          };
        } else {
          return result;
        }
      }

      // Обработка прямого ответа (для skipRefresh = true)
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body) as Map<String, dynamic>;
        final user = User.fromJson(userData);
        
        // Сохраняем userId
        await saveUserId(user.id);
        
        return {
          'success': true,
          'user': user,
        };
      } else {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMessage = responseData['detail'] as String? ?? 
            'Ошибка получения информации о пользователе';
        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } on http.ClientException {
      return {
        'success': false,
        'error': 'Ошибка подключения к серверу',
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

  // Выполнить запрос с автоматическим refresh при 401
  static Future<Map<String, dynamic>> _makeAuthenticatedRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
  }) async {
    // Первая попытка
    var headers = await getAuthHeaders();
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    http.Response response;
    switch (method.toUpperCase()) {
      case 'GET':
        response = await _client.get(
          Uri.parse('$baseUrl$_v1$endpoint'),
          headers: headers,
        );
        break;
      case 'POST':
        response = await _client.post(
          Uri.parse('$baseUrl$_v1$endpoint'),
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'PUT':
        response = await _client.put(
          Uri.parse('$baseUrl$_v1$endpoint'),
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'DELETE':
        response = await _client.delete(
          Uri.parse('$baseUrl$_v1$endpoint'),
          headers: headers,
        );
        break;
      default:
        return {
          'success': false,
          'error': 'Неподдерживаемый HTTP метод: $method',
        };
    }

    // Если получили 401, пробуем refresh token
    if (response.statusCode == 401) {
      final refreshResult = await refreshToken();

      if (refreshResult['success'] == true) {
        // Повторяем запрос с новым токеном
        headers = await getAuthHeaders();
        if (additionalHeaders != null) {
          headers.addAll(additionalHeaders);
        }

        switch (method.toUpperCase()) {
          case 'GET':
            response = await _client.get(
              Uri.parse('$baseUrl$_v1$endpoint'),
              headers: headers,
            );
            break;
          case 'POST':
            response = await _client.post(
              Uri.parse('$baseUrl$_v1$endpoint'),
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            );
            break;
          case 'PUT':
            response = await _client.put(
              Uri.parse('$baseUrl$_v1$endpoint'),
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            );
            break;
          case 'DELETE':
            response = await _client.delete(
              Uri.parse('$baseUrl$_v1$endpoint'),
              headers: headers,
            );
            break;
        }
      } else {
        // Refresh не удался, требуется повторный вход
        return {
          'success': false,
          'error': refreshResult['error'] ?? 'Требуется повторный вход',
          'requiresLogin': true,
        };
      }
    }

    // Обработка ответа
    try {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        final errorMessage = responseData['detail'] as String? ?? 
            'Ошибка запроса';
        return {
          'success': false,
          'error': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      // Если ответ не JSON (например, 204 No Content)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': null,
        };
      }
      return {
        'success': false,
        'error': 'Ошибка парсинга ответа: ${e.toString()}',
        'statusCode': response.statusCode,
      };
    }
  }

  // Публичные методы для выполнения запросов (будут использоваться в следующих фазах)
  static Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? headers}) async {
    return _makeAuthenticatedRequest(
      method: 'GET',
      endpoint: endpoint,
      additionalHeaders: headers,
    );
  }

  static Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    return _makeAuthenticatedRequest(
      method: 'POST',
      endpoint: endpoint,
      body: body,
      additionalHeaders: headers,
    );
  }

  static Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    return _makeAuthenticatedRequest(
      method: 'PUT',
      endpoint: endpoint,
      body: body,
      additionalHeaders: headers,
    );
  }

  static Future<Map<String, dynamic>> delete(String endpoint, {Map<String, String>? headers}) async {
    return _makeAuthenticatedRequest(
      method: 'DELETE',
      endpoint: endpoint,
      additionalHeaders: headers,
    );
  }

  // Проверить, авторизован ли пользователь
  static Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ==========================================
  // DECKS API
  // ==========================================

  // Получить все колоды пользователя
  static Future<Map<String, dynamic>> getUserDecks({int skip = 0, int limit = 100}) async {
    final result = await get('/decks?skip=$skip&limit=$limit');
    
    if (result['success'] == true) {
      final decksData = result['data'] as List;
      return {
        'success': true,
        'decks': decksData,
      };
    } else {
      return result;
    }
  }

  // Получить одну колоду
  static Future<Map<String, dynamic>> getDeck(String deckId) async {
    return get('/decks/$deckId');
  }

  // Создать колоду
  static Future<Map<String, dynamic>> createDeck({
    required String title,
    String? description,
  }) async {
    final body = <String, dynamic>{
      'title': title,
    };
    
    if (description != null && description.isNotEmpty) {
      body['description'] = description;
    }

    return post('/decks', body: body, headers: {'Idempotency-Key': _uuid.v4()});
  }

  // Обновить колоду
  static Future<Map<String, dynamic>> updateDeck({
    required String deckId,
    required int version,
    String? title,
    String? description,
    String? status,
  }) async {
    final body = <String, dynamic>{'version': version};

    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (status != null) body['status'] = status;

    return put('/decks/$deckId', body: body);
  }

  // Удалить колоду
  static Future<Map<String, dynamic>> deleteDeck(String deckId) async {
    return delete('/decks/$deckId');
  }

  // ==========================================
  // CARDS API
  // ==========================================

  // Получить карточки колоды
  static Future<Map<String, dynamic>> getDeckCards({
    required String deckId,
    int skip = 0,
    int limit = 100,
  }) async {
    final result = await get('/cards/decks/$deckId/cards?skip=$skip&limit=$limit');
    
    if (result['success'] == true) {
      final cardsData = result['data'] as List;
      return {
        'success': true,
        'cards': cardsData,
      };
    } else {
      return result;
    }
  }

  // Получить одну карточку
  static Future<Map<String, dynamic>> getCard(String cardId) async {
    return get('/cards/$cardId');
  }

  // Конвертировать простой формат content в CardContentWrite (block-формат)
  static Map<String, dynamic> _toBlockContent(Map<String, dynamic> content) {
    final front = content['front'];
    if (front is List) return content; // уже в block-формате

    final frontText = front as String? ?? '';
    final backText = content['back'] as String? ?? '';
    final imageId = content['image_id'] as String?;

    return {
      'front': [
        {'id': _uuid.v4(), 'type': 'text', 'content': frontText},
      ],
      'back': [
        {'id': _uuid.v4(), 'type': 'text', 'content': backText},
        if (imageId != null)
          {'id': _uuid.v4(), 'type': 'image', 'image_id': imageId},
      ],
    };
  }

  // Создать карточку в колоде
  static Future<Map<String, dynamic>> createCard({
    required String deckId,
    required Map<String, dynamic> content,
    String cardType = 'key_terms',
    int position = 0,
  }) async {
    final body = <String, dynamic>{
      'content': _toBlockContent(content),
      'position': position,
    };

    return post('/cards/decks/$deckId/cards', body: body, headers: {'Idempotency-Key': _uuid.v4()});
  }

  // Создать несколько карточек в колоде
  static Future<Map<String, dynamic>> createCards({
    required String deckId,
    required List<Map<String, dynamic>> cards,
  }) async {
    // Создаем карточки последовательно
    final results = <Map<String, dynamic>>[];
    String? lastError;

    for (var i = 0; i < cards.length; i++) {
      final card = cards[i];
      final result = await createCard(
        deckId: deckId,
        content: card['content'] as Map<String, dynamic>,
        cardType: card['card_type'] as String? ?? 'key_terms',
        position: card['position'] as int? ?? i,
      );

      if (result['success'] == true) {
        results.add(result['data'] as Map<String, dynamic>);
      } else {
        lastError = result['error'] as String?;
        // Продолжаем создавать остальные карточки даже при ошибке
      }
    }

    if (results.isEmpty && lastError != null) {
      return {
        'success': false,
        'error': lastError,
      };
    }

    return {
      'success': true,
      'cards': results,
      'created': results.length,
      'total': cards.length,
    };
  }

  // Обновить карточку
  static Future<Map<String, dynamic>> updateCard({
    required String cardId,
    required int version,
    Map<String, dynamic>? content,
    String? cardType,
    int? position,
    bool? isSuspended,
  }) async {
    final body = <String, dynamic>{'version': version};

    if (content != null) body['content'] = content;
    if (cardType != null) body['card_type'] = cardType;
    if (position != null) body['position'] = position;
    if (isSuspended != null) body['is_suspended'] = isSuspended;

    return put('/cards/$cardId', body: body);
  }

  // Удалить карточку
  static Future<Map<String, dynamic>> deleteCard(String cardId) async {
    return delete('/cards/$cardId');
  }

  // Генерировать карточки через ML
  static Future<Map<String, dynamic>> generateCards({
    required String text,
    int count = 5,
  }) async {
    final body = <String, dynamic>{
      'text': text,
      'count': count.clamp(1, 20),
    };

    final result = await post('/cards/generate', body: body);
    
    if (result['success'] == true) {
      final cardsData = result['data'] as List;
      return {
        'success': true,
        'cards': cardsData,
      };
    } else {
      return result;
    }
  }

  // ==========================================
  // REVIEW API
  // ==========================================

  // Получить карточки на повтор (due cards)
  static Future<Map<String, dynamic>> getDueCards({
    String? deckId,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.clamp(1, 100).toString(),
    };
    
    if (deckId != null) {
      queryParams['deck_id'] = deckId;
    }

    final queryString = queryParams.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    final result = await get('/review/due?$queryString');
    
    if (result['success'] == true) {
      final cardsData = result['data'] as List;
      return {
        'success': true,
        'cards': cardsData,
      };
    } else {
      return result;
    }
  }

  // Отправить оценку карточки (1-4)
  // rating: 1=Again, 2=Hard, 3=Good, 4=Easy
  static Future<Map<String, dynamic>> submitReview({
    required String userCardId,
    required int rating, // 1-4
    required int version,
    int durationMs = 0,
  }) async {
    if (rating < 1 || rating > 4) {
      return {
        'success': false,
        'error': 'Rating must be between 1 and 4',
      };
    }

    final body = <String, dynamic>{
      'rating': rating,
      'duration_ms': durationMs,
      'version': version,
    };

    return post('/review/$userCardId', body: body);
  }

  // Получить историю повторений карточки
  static Future<Map<String, dynamic>> getReviewHistory(String cardId) async {
    return get('/review/history/$cardId');
  }

  // ==========================================
  // IMAGES API
  // ==========================================

  // Получить presigned URL для загрузки изображения
  // contentType: MIME-тип, например 'image/jpeg', 'image/png', 'image/webp'
  static Future<Map<String, dynamic>> getImageUploadUrl({
    required String contentType,
  }) async {
    final result = await post('/images/', body: {'content_type': contentType});

    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>;
      return {
        'success': true,
        'image_id': data['image_id'] as String,
        'upload_url': data['upload_url'] as String,
        'method': data['method'] as String,
        'upload_fields': (data['upload_fields'] as Map<String, dynamic>?) ?? {},
        'required_headers': (data['required_headers'] as Map<String, dynamic>?) ?? {},
        'expires_in': data['expires_in'] as int,
        'object_name': data['object_name'] as String,
      };
    }
    return result;
  }

  // Загрузить файл по presigned URL (PUT или POST)
  static Future<bool> uploadFileToPresignedUrl({
    required String uploadUrl,
    required String method,
    required List<int> fileBytes,
    required String contentType,
    Map<String, dynamic> uploadFields = const {},
    Map<String, dynamic> requiredHeaders = const {},
  }) async {
    try {
      final headers = <String, String>{
        'Content-Type': contentType,
        for (final e in requiredHeaders.entries)
          e.key: e.value.toString(),
      };

      http.Response response;
      if (method.toUpperCase() == 'PUT') {
        response = await _client.put(
          Uri.parse(uploadUrl),
          headers: headers,
          body: fileBytes,
        );
      } else {
        final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
        uploadFields.forEach((k, v) => request.fields[k] = v.toString());
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: 'upload',
        ));
        final streamed = await _client.send(request);
        response = await http.Response.fromStream(streamed);
      }

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  // ==========================================
  // GENERATIONS API
  // ==========================================

  static Future<Map<String, dynamic>> getGenerations({
    int skip = 0,
    int limit = 50,
  }) async {
    final result = await get('/generations?skip=$skip&limit=$limit');
    if (result['success'] == true) {
      final data = result['data'];
      final list = data is List ? data : (data as Map<String, dynamic>?)?['items'] as List? ?? [];
      return {'success': true, 'generations': list};
    }
    return result;
  }
}

