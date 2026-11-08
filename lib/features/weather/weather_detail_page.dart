import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_weather_demo/data/models/location.dart';
import 'package:flutter_weather_demo/domain/location_label.dart';
import 'package:flutter_weather_demo/domain/map_codes.dart';
import 'package:flutter_weather_demo/features/common/error_state.dart';
import 'package:flutter_weather_demo/features/common/loading_state.dart';
import 'package:flutter_weather_demo/features/common/locale_switcher.dart';
import 'package:flutter_weather_demo/features/common/mood_gradient.dart';
import 'package:flutter_weather_demo/features/common/refresh_button.dart';
import 'package:flutter_weather_demo/features/weather/current_weather.dart';
import 'package:flutter_weather_demo/features/weather/daily_forecast.dart';
import 'package:flutter_weather_demo/features/weather/day_forecast_sheet.dart';
import 'package:flutter_weather_demo/features/weather/hourly_forecast.dart';
import 'package:flutter_weather_demo/l10n/error_messages.dart';
import 'package:flutter_weather_demo/l10n/messages.dart';
import 'package:flutter_weather_demo/state/app_state.dart';
import 'package:flutter_weather_demo/state/providers.dart';

class WeatherDetailPage extends ConsumerStatefulWidget {
  const WeatherDetailPage({super.key, required this.location});

  final SelectedLocation location;

  @override
  ConsumerState<WeatherDetailPage> createState() => _WeatherDetailPageState();
}

class _WeatherDetailPageState extends ConsumerState<WeatherDetailPage> {
  bool _resolvingLabel = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureLabel());
  }

  SelectedLocation _resolvedLocation(AppState app) {
    return app.favoriteById(widget.location.id) ??
        app.recentById(widget.location.id) ??
        widget.location;
  }

  Future<void> _ensureLabel() async {
    final app = ref.read(appControllerProvider);
    final location = _resolvedLocation(app);
    if (hasLocaleLabel(location, app.locale)) return;

    setState(() => _resolvingLabel = true);
    try {
      final label = await resolveLocationLabel(
        ref.read(geocodeApiProvider),
        location,
        app.locale,
      );
      if (label != null && mounted) {
        await ref
            .read(appControllerProvider.notifier)
            .patchLocationLabels(location.id, app.locale, label);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _resolvingLabel = false);
    }
  }

  Future<void> _toggleFavorite() async {
    final notifier = ref.read(appControllerProvider.notifier);
    var app = ref.read(appControllerProvider);
    var location = _resolvedLocation(app);

    if (notifier.isFavorite(location.id)) {
      await notifier.removeFavorite(location.id);
      return;
    }

    if (!hasLocaleLabel(location, app.locale)) {
      setState(() => _resolvingLabel = true);
      try {
        final label = await resolveLocationLabel(
          ref.read(geocodeApiProvider),
          location,
          app.locale,
        );
        if (label == null) return;
        await notifier.patchLocationLabels(location.id, app.locale, label);
        app = ref.read(appControllerProvider);
        location = _resolvedLocation(app);
      } catch (_) {
        return;
      } finally {
        if (mounted) setState(() => _resolvingLabel = false);
      }
    }

    final label = getLocationLabel(location, app.locale);
    await notifier.toggleFavorite(
      SelectedLocation(
        id: location.id,
        name: label.name,
        latitude: location.latitude,
        longitude: location.longitude,
        country: label.country,
        admin1: label.admin1,
        labels: {
          ...?location.labels,
          app.locale: label,
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = ref.watch(appControllerProvider);
    final locale = app.locale;
    final location = _resolvedLocation(app);
    final label = getLocationLabel(location, locale);
    final favorite = app.favoriteById(location.id) != null;
    final weatherKey = WeatherQueryKey.fromLocation(location);
    final weatherAsync = ref.watch(weatherProvider(weatherKey));
    final weather = weatherAsync.asData?.value;
    final mood = weather == null
        ? WeatherMood.rain
        : getWeatherMood(weather.current.weatherCode);
    final isDay = weather?.current.isDay ?? true;
    final initialLoading =
        !app.hydrated || (weatherAsync.isLoading && weather == null);
    final refreshing = weatherAsync.isLoading && weather != null;
    final showError = weatherAsync.hasError && weather == null;
    final favoriteBusy = _resolvingLabel && !favorite;

    return MoodGradient(
      mood: mood,
      isDay: isDay,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                    child: Row(
                      children: [
                        _ChromeButton(
                          tooltip: t(locale, 'backToList'),
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => context.go('/'),
                        ),
                        const Spacer(),
                        RefreshButton(busy: refreshing || weatherAsync.isLoading),
                        const SizedBox(width: 4),
                        _ChromeButton(
                          tooltip:
                              t(locale, favorite ? 'unfavorite' : 'favorite'),
                          icon: favorite ? Icons.star : Icons.star_border,
                          onTap: favoriteBusy ? null : _toggleFavorite,
                          busy: favoriteBusy,
                        ),
                        const SizedBox(width: 4),
                        LocaleSwitcher(onChanged: _ensureLabel),
                      ],
                    ),
                  ),
                  Expanded(
                    child: initialLoading
                        ? LoadingState(locale: locale)
                        : showError
                            ? ErrorState(
                                locale: locale,
                                message: getErrorMessage(
                                  weatherAsync.error!,
                                  locale,
                                ),
                                onRetry: () =>
                                    ref.invalidate(weatherProvider(weatherKey)),
                              )
                            : Opacity(
                                opacity: refreshing ? 0.55 : 1,
                                child: ListView(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 12, 16, 32),
                                  children: [
                                    CurrentWeatherPanel(
                                      weather: weather!,
                                      displayName: label.name,
                                      locale: locale,
                                      namePending:
                                          !hasLocaleLabel(location, locale) &&
                                              _resolvingLabel,
                                    ),
                                    const SizedBox(height: 28),
                                    HourlyForecast(
                                      weather: weather,
                                      locale: locale,
                                    ),
                                    const SizedBox(height: 28),
                                    DailyForecast(
                                      weather: weather,
                                      locale: locale,
                                      onDayTap: (day) {
                                        final isToday = day.date ==
                                            weather.current.time
                                                .substring(0, 10);
                                        showDayForecastSheet(
                                          context: context,
                                          weather: weather,
                                          day: day,
                                          locale: locale,
                                          isToday: isToday,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                  ),
                ],
              ),
              if (refreshing)
                const Positioned(
                  top: 64,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.white70,
                      strokeWidth: 2,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChromeButton extends StatelessWidget {
  const _ChromeButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.busy = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String tooltip;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.1),
        shape: const CircleBorder(
          side: BorderSide(color: Color(0x33FFFFFF)),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white70,
                      ),
                    )
                  : Icon(icon, color: Colors.white, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}
