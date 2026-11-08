import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter_weather_demo/core/api/api_error.dart';
import 'package:flutter_weather_demo/core/api/codes.dart';
import 'package:flutter_weather_demo/core/config.dart';

class ApiClient {
  ApiClient({http.Client? httpClient, String? baseUrl})
      : _http = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? normalizedApiBase;

  final http.Client _http;
  final String _baseUrl;

  Future<T> get<T>(
    String path, {
    required T Function(Map<String, dynamic> json) parse,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    late http.Response response;
    try {
      response = await _http.get(
        uri,
        headers: const {'Accept': 'application/json'},
      );
    } catch (_) {
      throw ApiError(ApiCode.unknown, 'Network request failed');
    }

    late Map<String, dynamic> payload;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected object');
      }
      payload = decoded;
    } catch (_) {
      throw ApiError(ApiCode.unknown, 'Invalid response format');
    }

    final code = payload['code'];
    final msg = payload['msg'];
    if (code is! int || msg is! String || !payload.containsKey('data')) {
      throw ApiError(ApiCode.unknown, 'Invalid response format');
    }

    if (code != ApiCode.success) {
      throw ApiError(code, msg);
    }

    final data = payload['data'];
    if (data == null) {
      throw ApiError(ApiCode.unknown, msg.isEmpty ? 'Empty response data' : msg);
    }
    if (data is! Map<String, dynamic>) {
      throw ApiError(ApiCode.unknown, 'Invalid response format');
    }

    return parse(data);
  }

  void close() => _http.close();
}
