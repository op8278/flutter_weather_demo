import 'package:flutter/material.dart';

import 'package:flutter_weather_demo/l10n/messages.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.locale,
    required this.message,
    required this.onRetry,
  });

  final String locale;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
                ),
              ),
              child: Text(t(locale, 'retry')),
            ),
          ],
        ),
      ),
    );
  }
}
