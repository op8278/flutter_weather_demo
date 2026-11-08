import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_weather_demo/data/models/location.dart';
import 'package:flutter_weather_demo/domain/location_label.dart';
import 'package:flutter_weather_demo/features/cities/city_card.dart';
import 'package:flutter_weather_demo/features/common/labels_resolver.dart';
import 'package:flutter_weather_demo/features/common/locale_switcher.dart';
import 'package:flutter_weather_demo/features/common/refresh_button.dart';
import 'package:flutter_weather_demo/features/search/location_search.dart';
import 'package:flutter_weather_demo/l10n/messages.dart';
import 'package:flutter_weather_demo/state/app_state.dart';
import 'package:flutter_weather_demo/state/providers.dart';

class CityListPage extends ConsumerStatefulWidget {
  const CityListPage({super.key});

  @override
  ConsumerState<CityListPage> createState() => _CityListPageState();
}

class _CityListPageState extends ConsumerState<CityListPage> {
  final _searchKey = GlobalKey<LocationSearchState>();
  int? _openSwipeId;

  @override
  Widget build(BuildContext context) {
    final app = ref.watch(appControllerProvider);
    final locale = app.locale;
    final favorites = app.favorites;

    return LabelsResolver(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1c2433), Color(0xFF10141c), Color(0xFF0b0e14)],
            stops: [0, 0.55, 1],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          t(locale, 'citiesTitle'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      RefreshButton(
                        busy: favorites.any(
                          (loc) => ref
                              .watch(
                                weatherProvider(
                                  WeatherQueryKey.fromLocation(loc),
                                ),
                              )
                              .isLoading,
                        ),
                      ),
                      LocaleSwitcher(
                        onChanged: () => _searchKey.currentState?.dismiss(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LocationSearch(
                    key: _searchKey,
                    onSelect: _handleSelect,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: !app.hydrated
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white70,
                            ),
                          )
                        : favorites.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(top: 24),
                                child: Text(
                                  t(locale, 'emptyFavorites'),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.65),
                                    fontSize: 15,
                                    height: 1.45,
                                  ),
                                ),
                              )
                            : NotificationListener<ScrollNotification>(
                                onNotification: (notification) {
                                  if (notification is ScrollStartNotification) {
                                    _searchKey.currentState?.dismiss();
                                    if (_openSwipeId != null) {
                                      setState(() => _openSwipeId = null);
                                    }
                                  }
                                  return false;
                                },
                                child: ListView.separated(
                                  padding: EdgeInsets.only(
                                    bottom:
                                        MediaQuery.paddingOf(context).bottom +
                                            24,
                                  ),
                                  itemCount: favorites.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final location = favorites[index];
                                    return CityCard(
                                      location: location,
                                      locale: locale,
                                      deleteOpen: _openSwipeId == location.id,
                                      onDeleteOpenChange: (open) {
                                        setState(() {
                                          _openSwipeId =
                                              open ? location.id : null;
                                        });
                                      },
                                      onNavigate: () {
                                        setState(() => _openSwipeId = null);
                                        _navigate(location, locale);
                                      },
                                      onRemove: () {
                                        ref
                                            .read(
                                              appControllerProvider.notifier,
                                            )
                                            .removeFavorite(location.id);
                                        setState(() => _openSwipeId = null);
                                      },
                                    );
                                  },
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSelect(SelectedLocation location) {
    setState(() => _openSwipeId = null);
    final locale = ref.read(appControllerProvider).locale;
    _navigate(location, locale);
  }

  void _navigate(SelectedLocation location, String locale) {
    final query = buildWeatherQuery(location, locale);
    final uri = Uri(path: '/weather/${location.id}', queryParameters: query);
    context.push(uri.toString());
  }
}
