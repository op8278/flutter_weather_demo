import 'package:flutter/material.dart';

import 'package:flutter_weather_demo/domain/map_codes.dart';

class MoodGradient extends StatelessWidget {
  const MoodGradient({
    super.key,
    required this.mood,
    required this.isDay,
    required this.child,
  });

  final WeatherMood mood;
  final bool isDay;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final stops = getBackgroundColors(mood, isDay);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: stops.map((s) => Color(s.argb)).toList(),
          stops: stops.map((s) => s.stop).toList(),
        ),
      ),
      child: child,
    );
  }
}
