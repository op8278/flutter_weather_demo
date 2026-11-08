import 'package:flutter/material.dart';

import 'package:flutter_weather_demo/l10n/messages.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Colors.white70),
          const SizedBox(height: 16),
          Text(
            t(locale, 'loading'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
