import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_weather_demo/core/api/api_client.dart';
import 'package:flutter_weather_demo/main.dart';
import 'package:flutter_weather_demo/state/providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Future.wait([
      initializeDateFormatting('en_US'),
      initializeDateFormatting('zh_CN'),
    ]);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('search city, open detail, favorite appears on list', (tester) async {
    final client = ApiClient(
      baseUrl: 'https://example.test',
      httpClient: MockClient((request) async {
        final path = request.url.path;
        if (path.endsWith('/api/geocode')) {
          return http.Response(
            jsonEncode({
              'code': 0,
              'msg': 'ok',
              'data': {
                'results': [
                  {
                    'id': 1850147,
                    'name': request.url.queryParameters['lang'] == 'zh'
                        ? '东京'
                        : 'Tokyo',
                    'latitude': 35.6895,
                    'longitude': 139.69171,
                    'country': request.url.queryParameters['lang'] == 'zh'
                        ? '日本'
                        : 'Japan',
                    'admin1': 'Tokyo',
                  },
                ],
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (path.endsWith('/api/weather')) {
          return http.Response(
            jsonEncode({
              'code': 0,
              'msg': 'ok',
              'data': {
                'location': {
                  'name': 'Tokyo',
                  'latitude': 35.6895,
                  'longitude': 139.69171,
                  'timezone': 'Asia/Tokyo',
                },
                'current': {
                  'time': '2026-11-08T15:00',
                  'temperature': 18.2,
                  'apparentTemperature': 17.0,
                  'humidity': 55,
                  'windSpeed': 12.3,
                  'weatherCode': 0,
                  'isDay': true,
                },
                'hourly': [
                  for (var h = 15; h < 24; h++)
                    {
                      'time':
                          '2026-11-08T${h.toString().padLeft(2, '0')}:00',
                      'temperature': 18.0 - (h - 15) * 0.4,
                      'weatherCode': 0,
                      'isDay': h < 18,
                    },
                ],
                'daily': [
                  for (var d = 0; d < 7; d++)
                    {
                      'date':
                          '2026-11-${(8 + d).toString().padLeft(2, '0')}',
                      'weatherCode': 0,
                      'tempMax': 20.0,
                      'tempMin': 12.0,
                      'precipitationProbabilityMax': d == 0 ? 10 : null,
                    },
                ],
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('not found', 404);
      }),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(client),
        ],
        child: const WeatherApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Weather'), findsOneWidget);
    expect(find.textContaining('No cities yet'), findsOneWidget);

    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Tokyo');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.textContaining('Tokyo'), findsWidgets);
    await tester.tap(find.textContaining('Tokyo, Tokyo, Japan').first);
    await tester.pumpAndSettle();

    expect(find.text('18°'), findsWidgets);
    expect(find.textContaining('Humidity'), findsOneWidget);
    expect(find.textContaining('HOURLY FORECAST'), findsOneWidget);
    expect(find.textContaining('7-DAY FORECAST'), findsOneWidget);
    expect(find.text('List'), findsOneWidget);
    expect(find.text('Chart'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.star_border));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Tokyo'), findsWidgets);
    expect(find.textContaining('No cities yet'), findsNothing);
  });
}
