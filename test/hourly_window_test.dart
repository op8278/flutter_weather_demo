import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_weather_demo/data/models/weather.dart';
import 'package:flutter_weather_demo/domain/hourly_window.dart';

HourlyForecastItem hour(String time, double temp) {
  return HourlyForecastItem(
    time: time,
    temperature: temp,
    weatherCode: 0,
    isDay: true,
  );
}

void main() {
  final items = [
    hour('2026-11-08T10:00', 10),
    hour('2026-11-08T11:00', 11),
    hour('2026-11-08T12:00', 12),
    hour('2026-11-09T00:00', 9),
  ];

  test('nextHours is inclusive from fromTime', () {
    final result = nextHours(items, count: 2, fromTime: '2026-11-08T11:00');
    expect(result.map((e) => e.time).toList(), [
      '2026-11-08T11:00',
      '2026-11-08T12:00',
    ]);
  });

  test('hoursForDate filters by calendar date', () {
    final result = hoursForDate(items, '2026-11-08');
    expect(result.length, 3);
  });

  test('todayDateFromCurrentTime uses date prefix', () {
    expect(todayDateFromCurrentTime('2026-11-08T15:30'), '2026-11-08');
  });
}
