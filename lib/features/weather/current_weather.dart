import 'package:flutter/material.dart';

import 'package:flutter_weather_demo/data/models/weather.dart';
import 'package:flutter_weather_demo/domain/map_codes.dart';
import 'package:flutter_weather_demo/features/weather/weather_icon.dart';
import 'package:flutter_weather_demo/l10n/messages.dart';

class CurrentWeatherPanel extends StatelessWidget {
  const CurrentWeatherPanel({
    super.key,
    required this.weather,
    required this.displayName,
    required this.locale,
    this.namePending = false,
  });

  final WeatherData weather;
  final String displayName;
  final String locale;
  final bool namePending;

  @override
  Widget build(BuildContext context) {
    final current = weather.current;
    return Column(
      children: [
        Text(
          namePending ? '$displayName…' : displayName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${current.temperature.round()}°',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 72,
            fontWeight: FontWeight.w200,
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WeatherIcon(
              code: current.weatherCode,
              isDay: current.isDay,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              getWeatherDescription(current.weatherCode, locale),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '${t(locale, 'feelsLike')} ${current.apparentTemperature.round()}°',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: t(locale, 'humidity'),
                value: '${current.humidity}%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatTile(
                label: t(locale, 'wind'),
                value: '${current.windSpeed.round()} km/h',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
