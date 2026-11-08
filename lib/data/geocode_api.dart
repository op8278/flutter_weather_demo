import 'package:flutter_weather_demo/core/api/api_client.dart';
import 'package:flutter_weather_demo/data/models/location.dart';

class GeocodeApi {
  GeocodeApi(this._client);

  final ApiClient _client;

  Future<GeocodeData> search(String query, String lang) {
    final q = Uri.encodeQueryComponent(query);
    return _client.get(
      '/api/geocode?q=$q&lang=$lang',
      parse: GeocodeData.fromJson,
    );
  }

  Future<GeocodeData> byId(int id, String lang) {
    return _client.get(
      '/api/geocode?id=$id&lang=$lang',
      parse: GeocodeData.fromJson,
    );
  }
}
