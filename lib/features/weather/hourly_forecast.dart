import 'package:flutter/material.dart';

import 'package:flutter_weather_demo/data/models/weather.dart';
import 'package:flutter_weather_demo/domain/hourly_window.dart';
import 'package:flutter_weather_demo/features/weather/temperature_curve.dart';
import 'package:flutter_weather_demo/features/weather/weather_icon.dart';
import 'package:flutter_weather_demo/l10n/messages.dart';

class HourlyForecast extends StatefulWidget {
  const HourlyForecast({
    super.key,
    required this.weather,
    required this.locale,
  });

  final WeatherData weather;
  final String locale;

  @override
  State<HourlyForecast> createState() => _HourlyForecastState();
}

class _HourlyForecastState extends State<HourlyForecast> {
  bool _chart = false;

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;
    final weather = widget.weather;
    final listItems = nextHours(
      weather.hourly,
      count: 24,
      fromTime: weather.current.time,
    );
    final today = todayDateFromCurrentTime(weather.current.time);
    final chartItems = hoursForDate(weather.hourly, today);
    final curveItems = chartItems.isEmpty ? listItems : chartItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                t(locale, 'hourly').toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 11,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  _Tab(
                    label: t(locale, 'hourlyList'),
                    selected: !_chart,
                    onTap: () => setState(() => _chart = false),
                  ),
                  _Tab(
                    label: t(locale, 'hourlyChart'),
                    selected: _chart,
                    onTap: () => setState(() => _chart = true),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_chart)
          TemperatureCurve(items: curveItems, locale: locale)
        else
          SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: listItems.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = listItems[index];
                final label = index == 0
                    ? t(locale, 'now')
                    : _formatHour(item.time, locale);
                return Container(
                  width: 76,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12,
                        ),
                      ),
                      WeatherIcon(
                        code: item.weatherCode,
                        isDay: item.isDay,
                        size: 28,
                      ),
                      Text(
                        '${item.temperature.round()}°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  String _formatHour(String time, String locale) {
    final hour = int.tryParse(time.substring(11, 13)) ?? 0;
    if (locale == 'zh') return '$hour时';
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$h12 ${hour < 12 ? 'AM' : 'PM'}';
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: selected ? 1 : 0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
