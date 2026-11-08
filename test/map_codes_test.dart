import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_weather_demo/domain/map_codes.dart';

void main() {
  test('maps clear and storm moods', () {
    expect(getWeatherMood(0), WeatherMood.clear);
    expect(getWeatherMood(95), WeatherMood.storm);
    expect(getWeatherMood(61), WeatherMood.rain);
  });

  test('maps icon kinds', () {
    expect(getWeatherIconKind(0), WeatherIconKind.clear);
    expect(getWeatherIconKind(45), WeatherIconKind.fog);
    expect(getWeatherIconKind(85), WeatherIconKind.snowShowers);
  });

  test('localizes descriptions with fallback', () {
    expect(getWeatherDescription(0, 'en'), 'Clear');
    expect(getWeatherDescription(0, 'zh'), '晴');
    expect(getWeatherDescription(999, 'en'), 'Unknown');
    expect(getWeatherDescription(999, 'zh'), '未知');
  });
}
