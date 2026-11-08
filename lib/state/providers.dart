import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_weather_demo/core/api/api_client.dart';
import 'package:flutter_weather_demo/data/geocode_api.dart';
import 'package:flutter_weather_demo/data/models/location.dart';
import 'package:flutter_weather_demo/data/models/weather.dart';
import 'package:flutter_weather_demo/data/weather_api.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient();
  ref.onDispose(client.close);
  return client;
});

final geocodeApiProvider = Provider<GeocodeApi>((ref) {
  return GeocodeApi(ref.watch(apiClientProvider));
});

final weatherApiProvider = Provider<WeatherApi>((ref) {
  return WeatherApi(ref.watch(apiClientProvider));
});

class WeatherQueryKey {
  const WeatherQueryKey(this.latitude, this.longitude, this.name);

  final double latitude;
  final double longitude;
  final String name;

  factory WeatherQueryKey.fromLocation(SelectedLocation location) {
    return WeatherQueryKey(
      location.latitude,
      location.longitude,
      location.name,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeatherQueryKey &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          name == other.name;

  @override
  int get hashCode => Object.hash(latitude, longitude, name);
}

final weatherProvider =
    FutureProvider.family<WeatherData, WeatherQueryKey>((ref, key) async {
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 5), link.close);
  ref.onDispose(timer.cancel);

  final location = SelectedLocation(
    id: 0,
    name: key.name,
    latitude: key.latitude,
    longitude: key.longitude,
    country: '',
  );
  return ref.watch(weatherApiProvider).fetch(location);
});

class GeocodeQuery {
  const GeocodeQuery(this.query, this.locale);

  final String query;
  final String locale;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeocodeQuery && query == other.query && locale == other.locale;

  @override
  int get hashCode => Object.hash(query, locale);
}

final geocodeProvider =
    FutureProvider.family<GeocodeData, GeocodeQuery>((ref, key) async {
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 5), link.close);
  ref.onDispose(timer.cancel);
  return ref.watch(geocodeApiProvider).search(key.query, key.locale);
});

Future<LocationLabel?> resolveLocationLabel(
  GeocodeApi api,
  SelectedLocation location,
  String locale,
) async {
  final data = await api.byId(location.id, locale);
  if (data.results.isEmpty) return null;
  final match = data.results.first;
  if (match.id != location.id) return null;
  return LocationLabel(
    name: match.name,
    country: match.country,
    admin1: match.admin1,
  );
}
