import 'package:flutter_weather_demo/data/models/weather.dart';

String dateKey(String time) => time.substring(0, 10);

/// Next [count] hours from [fromTime] (inclusive). Lexicographic compare is
/// valid for Open-Meteo local `YYYY-MM-DDTHH:mm` strings.
List<HourlyForecastItem> nextHours(
  List<HourlyForecastItem> items, {
  int count = 24,
  String? fromTime,
}) {
  final upcoming = fromTime == null
      ? items
      : items.where((item) => item.time.compareTo(fromTime) >= 0);
  return upcoming.take(count).toList();
}

List<HourlyForecastItem> hoursForDate(
  List<HourlyForecastItem> items,
  String date,
) {
  return items.where((item) => dateKey(item.time) == date).toList();
}

/// Open-Meteo `current.time` is already in the location timezone.
String todayDateFromCurrentTime(String currentTime) => dateKey(currentTime);
