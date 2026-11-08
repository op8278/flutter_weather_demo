import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_weather_demo/data/models/location.dart';
import 'package:flutter_weather_demo/domain/location_label.dart';
import 'package:flutter_weather_demo/state/app_state.dart';
import 'package:flutter_weather_demo/state/providers.dart';

/// Resolves missing localized labels for favorites and recent searches.
class LabelsResolver extends ConsumerStatefulWidget {
  const LabelsResolver({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<LabelsResolver> createState() => _LabelsResolverState();
}

class _LabelsResolverState extends ConsumerState<LabelsResolver> {
  String? _lastLocale;
  final Set<int> _inFlight = {};

  @override
  Widget build(BuildContext context) {
    final app = ref.watch(appControllerProvider);
    if (app.hydrated) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _resolve(app));
    }
    return widget.child;
  }

  Future<void> _resolve(AppState app) async {
    if (_lastLocale != app.locale) {
      _lastLocale = app.locale;
      _inFlight.clear();
    }

    final missing = <SelectedLocation>[];
    final seen = <int>{};
    for (final loc in [...app.favorites, ...app.recent]) {
      if (!hasLocaleLabel(loc, app.locale) &&
          !_inFlight.contains(loc.id) &&
          seen.add(loc.id)) {
        missing.add(loc);
      }
    }
    if (missing.isEmpty) return;

    _inFlight.addAll(missing.map((e) => e.id));
    final api = ref.read(geocodeApiProvider);
    final updates = <({int id, LocationLabel label})>[];

    for (final loc in missing) {
      try {
        final label = await resolveLocationLabel(api, loc, app.locale);
        if (label != null) {
          updates.add((id: loc.id, label: label));
        }
      } catch (_) {}
    }

    if (updates.isNotEmpty && mounted) {
      await ref
          .read(appControllerProvider.notifier)
          .patchLocationLabelsBatch(app.locale, updates);
    }
  }
}
