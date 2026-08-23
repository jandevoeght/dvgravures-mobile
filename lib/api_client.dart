import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'config.dart';
import 'models.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  const ApiException(this.message, {this.statusCode, this.code});

  @override
  String toString() => message;
}

class ApiClient {
  final http.Client _http;
  final FlutterSecureStorage _storage;
  String? _token;

  ApiClient({
    http.Client? httpClient,
    FlutterSecureStorage? storage,
  })  : _http = httpClient ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'dv_api_token';

  Future<void> loadToken() async {
    _token = await _storage.read(key: _tokenKey);
  }

  bool get hasToken => _token?.isNotEmpty == true;

  Map<String, String> _headers({bool json = false}) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (json) headers['Content-Type'] = 'application/json';
    if (_token?.isNotEmpty == true) {
      headers['Authorization'] = 'Bearer $_token';
      headers['X-DV-API-Token'] = _token!;
    }
    return headers;
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = Uri.parse('${AppConfig.apiBaseUrl}/$path');
    return query == null ? base : base.replace(queryParameters: query);
  }

  Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic> data;
    try {
      final decoded = jsonDecode(response.body);
      data = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{'data': decoded};
    } catch (_) {
      throw ApiException(
        'De server gaf geen geldige JSON terug.',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        data['message']?.toString() ??
            data['error']?.toString() ??
            'API-fout ${response.statusCode}',
        statusCode: response.statusCode,
        code: data['error']?.toString(),
      );
    }
    return data;
  }

  Future<ApiUser> login({
    required String username,
    required String password,
    String deviceName = 'DV Gravures Mobile',
  }) async {
    final response = await _http.post(
      _uri('login.php'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      },
      body: {
        'username': username,
        'password': password,
        'device_name': deviceName,
      },
    );
    final data = _decode(response);
    final token = data['token']?.toString();
    if (token == null || token.isEmpty) {
      throw const ApiException('Geen API-token ontvangen.');
    }
    _token = token;
    await _storage.write(key: _tokenKey, value: token);
    return ApiUser.fromJson(
      Map<String, dynamic>.from(data['user'] as Map? ?? const {}),
    );
  }

  Future<void> logout() async {
    try {
      if (hasToken) {
        await _http.post(_uri('logout.php'), headers: _headers());
      }
    } finally {
      _token = null;
      await _storage.delete(key: _tokenKey);
    }
  }

  Future<ApiUser> me() async {
    final response = await _http.get(_uri('me.php'), headers: _headers());
    final data = _decode(response);
    return ApiUser.fromJson(
      Map<String, dynamic>.from(data['user'] as Map? ?? const {}),
    );
  }

  Future<List<WorkTask>> tasks({String scope = 'open', int? orderId, String? date}) async {
    final query = <String, String>{'scope': scope};
    if (orderId != null) query['order_id'] = '$orderId';
    if (date != null && date.trim().isNotEmpty) query['date'] = date.trim();
    final response =
        await _http.get(_uri('tasks.php', query), headers: _headers());
    final data = _decode(response);
    final list = (data['tasks'] as List? ?? const []);
    return list
        .whereType<Map>()
        .map((e) => WorkTask.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<WorkOrderSummary>> orders({String query = ''}) async {
    final response = await _http.get(
      _uri('orders.php', {
        'limit': '100',
        if (query.trim().isNotEmpty) 'q': query.trim(),
      }),
      headers: _headers(),
    );
    final data = _decode(response);
    final list = (data['orders'] as List? ?? const []);
    return list
        .whereType<Map>()
        .map((e) => WorkOrderSummary.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Map<String, dynamic>> order(int id) async {
    final response = await _http.get(
      _uri('order.php', {'id': '$id'}),
      headers: _headers(),
    );
    return _decode(response);
  }


  String absoluteUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    final parsed = Uri.tryParse(trimmed);
    if (parsed != null && parsed.hasScheme) return trimmed;

    final api = Uri.parse(AppConfig.apiBaseUrl);
    final origin = '${api.scheme}://${api.authority}';
    if (trimmed.startsWith('/')) return '$origin$trimmed';
    return '$origin/${trimmed.replaceFirst(RegExp(r'^/+'), '')}';
  }

  Future<Uint8List> photoBytes(int photoId) async {
    final response = await _http.get(
      _uri('photo.php', {'id': '$photoId'}),
      headers: _headers(),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Foto kon niet worden geladen.';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          message = decoded['message'].toString();
        }
      } catch (_) {}
      throw ApiException(
        message,
        statusCode: response.statusCode,
      );
    }
    if (response.bodyBytes.isEmpty) {
      throw const ApiException('De foto is leeg.');
    }
    return response.bodyBytes;
  }

  Future<List<OrderPhoto>> photos(int orderId) async {
    final response = await _http.get(
      _uri('photos.php', {'order_id': '$orderId'}),
      headers: _headers(),
    );
    final data = _decode(response);
    final list = (data['photos'] as List? ?? const []);
    return list
        .whereType<Map>()
        .map((e) {
          final photo = OrderPhoto.fromJson(Map<String, dynamic>.from(e));
          return OrderPhoto(
            id: photo.id,
            photoType: photo.photoType,
            originalFilename: photo.originalFilename,
            caption: photo.caption,
            takenAt: photo.takenAt,
            url: absoluteUrl(photo.url),
          );
        })
        .toList();
  }

  Future<OrderPhoto> uploadPhoto({
    required int orderId,
    required File file,
    String caption = '',
    String photoType = 'Mobiele app',
  }) async {
    final request = http.MultipartRequest(
      'POST',
      _uri('photos.php', {'order_id': '$orderId'}),
    );
    request.headers.addAll(_headers());
    request.fields['caption'] = caption;
    request.fields['photo_type'] = photoType;
    request.fields['taken_at'] = DateTime.now().toIso8601String();
    request.files.add(await http.MultipartFile.fromPath('photo', file.path));

    final streamed = await _http.send(request);
    final response = await http.Response.fromStream(streamed);
    final data = _decode(response);
    final photo = OrderPhoto.fromJson(
      Map<String, dynamic>.from(data['photo'] as Map? ?? const {}),
    );
    return OrderPhoto(
      id: photo.id,
      photoType: photo.photoType,
      originalFilename: photo.originalFilename,
      caption: photo.caption,
      takenAt: photo.takenAt,
      url: absoluteUrl(photo.url),
    );
  }


  Future<void> updatePhotoCaption(int photoId, String caption) async {
    final response = await _http.post(
      _uri('photo-action.php'),
      headers: _headers(json: true),
      body: jsonEncode({
        'id': photoId,
        'action': 'caption',
        'caption': caption,
      }),
    );
    _decode(response);
  }

  Future<void> deletePhoto(int photoId) async {
    final response = await _http.post(
      _uri('photo-action.php'),
      headers: _headers(json: true),
      body: jsonEncode({
        'id': photoId,
        'action': 'delete',
      }),
    );
    _decode(response);
  }

  Future<void> updateTaskNote(int taskId, String note) async {
    final response = await _http.post(
      _uri('task-note.php'),
      headers: _headers(json: true),
      body: jsonEncode({'task_id': taskId, 'note': note}),
    );
    _decode(response);
  }

  Future<void> completeManualTask(int taskId) async {
    final response = await _http.post(
      _uri('task-complete.php'),
      headers: _headers(json: true),
      body: jsonEncode({'task_id': taskId}),
    );
    _decode(response);
  }

  void close() => _http.close();
}
