import 'package:flutter_weather_demo/core/api/api_client.dart';
import 'package:flutter_weather_demo/data/models/location.dart';
import 'package:flutter_weather_demo/data/models/weather.dart';

class WeatherApi {
  WeatherApi(this._client);

  final ApiClient _client;

  Future<WeatherData> fetch(SelectedLocation location) {
    final params = {
      'lat': location.latitude.toString(),
      'lon': location.longitude.toString(),
      'name': location.name,
    };
    final query = Uri(queryParameters: params).query;
    return _client.get(
      '/api/weather?$query',
      parse: WeatherData.fromJson,
    );
  }
}
