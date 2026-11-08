import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_weather_demo/data/models/location.dart';

const _prefsKey = 'weather-app-store';

class AppState {
  const AppState({
    this.locale = 'en',
    this.recent = const [],
    this.favorites = const [],
    this.hydrated = false,
  });

  final String locale;
  final List<SelectedLocation> recent;
  final List<SelectedLocation> favorites;
  final bool hydrated;

  AppState copyWith({
    String? locale,
    List<SelectedLocation>? recent,
    List<SelectedLocation>? favorites,
    bool? hydrated,
  }) {
    return AppState(
      locale: locale ?? this.locale,
      recent: recent ?? this.recent,
      favorites: favorites ?? this.favorites,
      hydrated: hydrated ?? this.hydrated,
    );
  }

  SelectedLocation? favoriteById(int id) {
    for (final item in favorites) {
      if (item.id == id) return item;
    }
    return null;
  }

  SelectedLocation? recentById(int id) {
    for (final item in recent) {
      if (item.id == id) return item;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'locale': locale,
        'recent': recent.map((e) => e.toJson()).toList(),
        'favorites': favorites.map((e) => e.toJson()).toList(),
      };

  factory AppState.fromJson(Map<String, dynamic> json) {
    final favoritesRaw = json['favorites'];
    final recentRaw = json['recent'];
    return AppState(
      locale: json['locale'] == 'zh' ? 'zh' : 'en',
      recent: recentRaw is List
          ? recentRaw
              .map((e) => SelectedLocation.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ))
              .toList()
          : const [],
      favorites: favoritesRaw is List
          ? favoritesRaw
              .map((e) => SelectedLocation.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ))
              .toList()
          : const [],
      hydrated: true,
    );
  }
}

SelectedLocation mergeLocation(
  SelectedLocation? existing,
  SelectedLocation next,
) {
  if (existing == null) return next;
  return SelectedLocation(
    id: next.id,
    name: next.name,
    latitude: next.latitude,
    longitude: next.longitude,
    country: next.country,
    admin1: next.admin1 ?? existing.admin1,
    timezone: next.timezone ?? existing.timezone,
    labels: {
      ...?existing.labels,
      ...?next.labels,
    },
  );
}

List<SelectedLocation> patchList(
  List<SelectedLocation> list,
  int id,
  String locale,
  LocationLabel label,
) {
  return list
      .map((item) => item.id == id ? item.withLabel(locale, label) : item)
      .toList();
}

class AppController extends Notifier<AppState> {
  SharedPreferences? _prefs;

  @override
  AppState build() {
    Future.microtask(hydrate);
    return const AppState();
  }

  Future<void> hydrate() async {
    if (state.hydrated) return;
    _prefs ??= await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_prefsKey);
    if (raw == null) {
      state = state.copyWith(hydrated: true);
      return;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        state = AppState.fromJson(decoded);
        return;
      }
    } catch (_) {}
    state = state.copyWith(hydrated: true);
  }

  Future<void> _persist() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_prefsKey, jsonEncode(state.toJson()));
  }

  Future<void> setLocale(String locale) async {
    state = state.copyWith(locale: locale == 'zh' ? 'zh' : 'en');
    await _persist();
  }

  Future<void> addRecent(SelectedLocation location) async {
    final recent = [
      location,
      ...state.recent.where((item) => item.id != location.id),
    ].take(5).toList();
    state = state.copyWith(recent: recent);
    await _persist();
  }

  Future<void> removeRecent(int id) async {
    state = state.copyWith(
      recent: state.recent.where((item) => item.id != id).toList(),
    );
    await _persist();
  }

  Future<void> clearRecent() async {
    state = state.copyWith(recent: const []);
    await _persist();
  }

  Future<void> toggleFavorite(SelectedLocation location) async {
    final existing =
        state.favorites.where((item) => item.id == location.id).firstOrNull;
    if (existing != null) {
      state = state.copyWith(
        favorites:
            state.favorites.where((item) => item.id != location.id).toList(),
      );
    } else {
      state = state.copyWith(
        favorites: [...state.favorites, mergeLocation(existing, location)],
      );
    }
    await _persist();
  }

  Future<void> removeFavorite(int id) async {
    state = state.copyWith(
      favorites: state.favorites.where((item) => item.id != id).toList(),
    );
    await _persist();
  }

  bool isFavorite(int id) =>
      state.favorites.any((item) => item.id == id);

  SelectedLocation? getFavorite(int id) {
    for (final item in state.favorites) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<void> patchLocationLabels(
    int id,
    String locale,
    LocationLabel label,
  ) async {
    state = state.copyWith(
      favorites: patchList(state.favorites, id, locale, label),
      recent: patchList(state.recent, id, locale, label),
    );
    await _persist();
  }

  Future<void> patchLocationLabelsBatch(
    String locale,
    List<({int id, LocationLabel label})> updates,
  ) async {
    if (updates.isEmpty) return;
    var favorites = state.favorites;
    var recent = state.recent;
    for (final update in updates) {
      favorites = patchList(favorites, update.id, locale, update.label);
      recent = patchList(recent, update.id, locale, update.label);
    }
    state = state.copyWith(favorites: favorites, recent: recent);
    await _persist();
  }
}

final appControllerProvider =
    NotifierProvider<AppController, AppState>(AppController.new);
