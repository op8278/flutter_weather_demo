import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_weather_demo/data/models/weather.dart';
import 'package:flutter_weather_demo/domain/hourly_window.dart';
import 'package:flutter_weather_demo/domain/map_codes.dart';
import 'package:flutter_weather_demo/features/weather/temperature_curve.dart';
import 'package:flutter_weather_demo/features/weather/weather_icon.dart';
import 'package:flutter_weather_demo/l10n/messages.dart';

Future<void> showDayForecastSheet({
  required BuildContext context,
  required WeatherData weather,
  required DailyForecastItem day,
  required String locale,
  required bool isToday,
}) {
  final hours = hoursForDate(weather.hourly, day.date);
  final title = isToday
      ? t(locale, 'today')
      : DateFormat('EEE', locale == 'zh' ? 'zh_CN' : 'en_US')
          .format(DateTime.parse('${day.date}T12:00:00'));

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    // Keep sheet background flush with the screen edge; pad content instead.
    useSafeArea: false,
    builder: (context) {
      final bottomInset = MediaQuery.paddingOf(context).bottom;
      return Container(
        margin: const EdgeInsets.only(top: 48),
        decoration: BoxDecoration(
          color: const Color(0xF21a2744),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  WeatherIcon(code: day.weatherCode, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      t(locale, 'close'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${getWeatherDescription(day.weatherCode, locale)} · '
                  '${t(locale, 'high')} ${day.tempMax.round()}° · '
                  '${t(locale, 'low')} ${day.tempMin.round()}°',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (hours.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    t(locale, 'errorGeneric'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                )
              else
                TemperatureCurve(items: hours, locale: locale),
            ],
          ),
        ),
      );
    },
  );
}
