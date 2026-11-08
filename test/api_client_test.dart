import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:flutter_weather_demo/core/api/api_client.dart';
import 'package:flutter_weather_demo/core/api/api_error.dart';
import 'package:flutter_weather_demo/core/api/codes.dart';

void main() {
  test('parses success envelope regardless of HTTP status', () async {
    final client = ApiClient(
      baseUrl: 'https://example.test',
      httpClient: MockClient((request) async {
        return http.Response(
          jsonEncode({
            'code': 0,
            'msg': 'ok',
            'data': {'hello': 'world'},
          }),
          500,
        );
      }),
    );

    final data = await client.get(
      '/api/x',
      parse: (json) => json['hello'] as String,
    );
    expect(data, 'world');
  });

  test('throws ApiError when code != 0', () async {
    final client = ApiClient(
      baseUrl: 'https://example.test',
      httpClient: MockClient((request) async {
        return http.Response(
          jsonEncode({
            'code': ApiCode.locationNotFound,
            'msg': 'No locations found',
            'data': null,
          }),
          200,
        );
      }),
    );

    expect(
      () => client.get('/api/x', parse: (json) => json),
      throwsA(
        isA<ApiError>().having(
          (e) => e.code,
          'code',
          ApiCode.locationNotFound,
        ),
      ),
    );
  });

  test('throws unknown on invalid JSON', () async {
    final client = ApiClient(
      baseUrl: 'https://example.test',
      httpClient: MockClient((request) async {
        return http.Response('not-json', 200);
      }),
    );

    expect(
      () => client.get('/api/x', parse: (json) => json),
      throwsA(
        isA<ApiError>().having((e) => e.code, 'code', ApiCode.unknown),
      ),
    );
  });
}
