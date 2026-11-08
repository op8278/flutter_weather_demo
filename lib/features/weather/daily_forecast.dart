import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_weather_demo/data/models/weather.dart';
import 'package:flutter_weather_demo/domain/map_codes.dart';
import 'package:flutter_weather_demo/features/weather/weather_icon.dart';
import 'package:flutter_weather_demo/l10n/messages.dart';

class DailyForecast extends StatelessWidget {
  const DailyForecast({
    super.key,
    required this.weather,
    required this.locale,
    required this.onDayTap,
  });

  final WeatherData weather;
  final String locale;
  final ValueChanged<DailyForecastItem> onDayTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t(locale, 'daily').toUpperCase(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 11,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...weather.daily.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          final weekday = index == 0
              ? t(locale, 'today')
              : _weekday(day.date, locale);
          final precip = day.precipitationProbabilityMax;

          return InkWell(
            onTap: () => onDayTap(day),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 72,
                    child: Text(
                      weekday,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  WeatherIcon(code: day.weatherCode, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getWeatherDescription(day.weatherCode, locale),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                        if (precip != null)
                          Text(
                            '${t(locale, 'precip')} $precip%',
                            style: TextStyle(
                              color: const Color(0xFFBAE6FD).withValues(alpha: 0.8),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '${day.tempMax.round()}° / ${day.tempMin.round()}°',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  String _weekday(String date, String locale) {
    final dt = DateTime.parse('${date}T12:00:00');
    final formatter = DateFormat('EEE', locale == 'zh' ? 'zh_CN' : 'en_US');
    return formatter.format(dt);
  }
}
