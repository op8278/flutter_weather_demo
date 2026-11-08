import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_weather_demo/data/models/location.dart';
import 'package:flutter_weather_demo/domain/location_label.dart';
import 'package:flutter_weather_demo/domain/map_codes.dart';
import 'package:flutter_weather_demo/features/common/mood_gradient.dart';
import 'package:flutter_weather_demo/l10n/messages.dart';
import 'package:flutter_weather_demo/state/providers.dart';

class CityCard extends ConsumerWidget {
  const CityCard({
    super.key,
    required this.location,
    required this.locale,
    required this.deleteOpen,
    required this.onDeleteOpenChange,
    required this.onNavigate,
    required this.onRemove,
  });

  final SelectedLocation location;
  final String locale;
  final bool deleteOpen;
  final ValueChanged<bool> onDeleteOpenChange;
  final VoidCallback onNavigate;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(
      weatherProvider(WeatherQueryKey.fromLocation(location)),
    );
    final label = getLocationLabel(location, locale);
    final weather = weatherAsync.asData?.value;
    final mood = weather == null
        ? WeatherMood.cloudy
        : getWeatherMood(weather.current.weatherCode);
    final isDay = weather?.current.isDay ?? true;
    final refreshing = weatherAsync.isLoading && weather != null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 72,
                  color: const Color(0xFFE11D48),
                  alignment: Alignment.center,
                  child: Text(
                    t(locale, 'removeCity'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: deleteOpen ? -72.0 : 0.0),
            duration: const Duration(milliseconds: 180),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(value, 0),
                child: child,
              );
            },
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx < -4) onDeleteOpenChange(true);
                if (details.delta.dx > 4) onDeleteOpenChange(false);
              },
              onTap: () {
                if (deleteOpen) {
                  onDeleteOpenChange(false);
                  return;
                }
                onNavigate();
              },
              child: MoodGradient(
                mood: mood,
                isDay: isDay,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  label.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                weather == null
                                    ? '–'
                                    : '${weather.current.temperature.round()}°',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 42,
                                  fontWeight: FontWeight.w200,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  formatSubtitle(label),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.75),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Text(
                                weather == null
                                    ? '${t(locale, 'high')} –  ${t(locale, 'low')} –'
                                    : '${t(locale, 'high')} ${weather.daily.first.tempMax.round()}°  ${t(locale, 'low')} ${weather.daily.first.tempMin.round()}°',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          if (weatherAsync.hasError && weather == null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                t(locale, 'errorGeneric'),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (refreshing)
                      Positioned.fill(
                        child: ColoredBox(
                          color: Colors.black.withValues(alpha: 0.4),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white70,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
