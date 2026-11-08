import 'package:flutter_weather_demo/data/models/location.dart';

LocationLabel getLocationLabel(SelectedLocation location, String locale) {
  return location.labels?[locale] ??
      LocationLabel(
        name: location.name,
        country: location.country,
        admin1: location.admin1,
      );
}

bool hasLocaleLabel(SelectedLocation location, String locale) {
  final name = location.labels?[locale]?.name;
  return name != null && name.isNotEmpty;
}

String formatLocationLabel(LocationLabel label) {
  return [label.name, label.admin1, label.country]
      .where((part) => part != null && part.isNotEmpty)
      .join(', ');
}

String formatSubtitle(LocationLabel label) {
  return [label.admin1, label.country]
      .where((part) => part != null && part.isNotEmpty)
      .join(', ');
}

SelectedLocation? parseLocationFromQuery({
  required int id,
  required Map<String, String> query,
}) {
  final lat = double.tryParse(query['lat'] ?? '');
  final lon = double.tryParse(query['lon'] ?? '');
  final name = query['name']?.trim();

  if (name == null || name.isEmpty || lat == null || lon == null) {
    return null;
  }
  if (lat < -90 || lat > 90 || lon < -180 || lon > 180) {
    return null;
  }

  final admin1 = query['admin1'];
  return SelectedLocation(
    id: id,
    name: name,
    latitude: lat,
    longitude: lon,
    country: query['country'] ?? '',
    admin1: (admin1 == null || admin1.isEmpty) ? null : admin1,
  );
}

Map<String, String> buildWeatherQuery(
  SelectedLocation location,
  String locale,
) {
  final label = getLocationLabel(location, locale);
  return {
    'lat': location.latitude.toString(),
    'lon': location.longitude.toString(),
    'name': label.name,
    if (label.country.isNotEmpty) 'country': label.country,
    if (label.admin1 != null && label.admin1!.isNotEmpty) 'admin1': label.admin1!,
  };
}
