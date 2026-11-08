import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_weather_demo/l10n/messages.dart';
import 'package:flutter_weather_demo/state/app_state.dart';
import 'package:flutter_weather_demo/state/providers.dart';

class RefreshButton extends ConsumerWidget {
  const RefreshButton({super.key, this.busy = false});

  final bool busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appControllerProvider.select((s) => s.locale));

    return IconButton(
      tooltip: t(locale, 'refresh'),
      onPressed: busy
          ? null
          : () {
              ref.invalidate(weatherProvider);
            },
      icon: busy
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white70,
              ),
            )
          : const Icon(Icons.refresh, color: Colors.white),
    );
  }
}
