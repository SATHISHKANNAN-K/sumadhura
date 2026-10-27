import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/visitor.dart';

/// Set the URL using:
/// flutter run --dart-define=VISITOR_API_BASE_URL=https://YOUR_PROJECT.mockapi.io/api/v1
class VisitorApi {
  VisitorApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const String _configuredUrl = String.fromEnvironment(
      'VISITOR_API_BASE_URL',
      defaultValue: 'https://6ae03e448e42963c8d5f305b.mockapi.io/api/v1');
  static const Duration _timeout = Duration(seconds: 15);

  String get baseUrl => _configuredUrl.trim().replaceAll(RegExp(r'/$'), '');

  Uri _uri([String? id]) {
    if (baseUrl.isEmpty) {
      throw const ApiException(
        'API URL is not configured. Add VISITOR_API_BASE_URL when running the app. See README.md.',
      );
    }
    return Uri.parse(
        '$baseUrl/visitors${id == null ? '' : '/${Uri.encodeComponent(id)}'}');
  }

  Map<String, String> get _headers => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<List<Visitor>> getVisitors() async {
    final response =
        await _client.get(_uri(), headers: _headers).timeout(_timeout);
    _check(response);
    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const ApiException('Unexpected visitor list response from API.');
    }
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Visitor.fromJson)
        .toList();
  }

  Future<Visitor> getVisitor(String id) async {
    final response =
        await _client.get(_uri(id), headers: _headers).timeout(_timeout);
    _check(response);
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException('Unexpected visitor response from API.');
    }
    return Visitor.fromJson(decoded);
  }

  Future<Visitor> createVisitor(Visitor visitor) async {
    final body = visitor.toJson()..remove('id');
    final response = await _client
        .post(_uri(), headers: _headers, body: jsonEncode(body))
        .timeout(_timeout);
    _check(response);
    return Visitor.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Visitor> updateVisitor(Visitor visitor) async {
    final response = await _client
        .put(
          _uri(visitor.id),
          headers: _headers,
          body: jsonEncode(visitor.toJson()),
        )
        .timeout(_timeout);
    _check(response);
    return Visitor.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteVisitor(String id) async {
    final response =
        await _client.delete(_uri(id), headers: _headers).timeout(_timeout);
    _check(response, allowEmpty: true);
  }

  void _check(http.Response response, {bool allowEmpty = false}) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    if (allowEmpty && response.statusCode == 204) return;
    var message = 'Request failed (${response.statusCode}).';
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['message'] != null) {
        message = body['message'].toString();
      }
    } catch (_) {}
    throw ApiException(message);
  }
}

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}
