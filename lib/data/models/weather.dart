class HourlyForecastItem {
  const HourlyForecastItem({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.isDay,
  });

  final String time;
  final double temperature;
  final int weatherCode;
  final bool isDay;

  factory HourlyForecastItem.fromJson(Map<String, dynamic> json) {
    return HourlyForecastItem(
      time: json['time'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      weatherCode: (json['weatherCode'] as num).toInt(),
      isDay: json['isDay'] as bool? ?? true,
    );
  }
}

class DailyForecastItem {
  const DailyForecastItem({
    required this.date,
    required this.weatherCode,
    required this.tempMax,
    required this.tempMin,
    required this.precipitationProbabilityMax,
  });

  final String date;
  final int weatherCode;
  final double tempMax;
  final double tempMin;
  final int? precipitationProbabilityMax;

  factory DailyForecastItem.fromJson(Map<String, dynamic> json) {
    final precip = json['precipitationProbabilityMax'];
    return DailyForecastItem(
      date: json['date'] as String,
      weatherCode: (json['weatherCode'] as num).toInt(),
      tempMax: (json['tempMax'] as num).toDouble(),
      tempMin: (json['tempMin'] as num).toDouble(),
      precipitationProbabilityMax: precip == null ? null : (precip as num).toInt(),
    );
  }
}

class CurrentWeather {
  const CurrentWeather({
    required this.time,
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.isDay,
  });

  final String time;
  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final double windSpeed;
  final int weatherCode;
  final bool isDay;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      time: json['time'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      apparentTemperature: (json['apparentTemperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toInt(),
      windSpeed: (json['windSpeed'] as num).toDouble(),
      weatherCode: (json['weatherCode'] as num).toInt(),
      isDay: json['isDay'] as bool? ?? true,
    );
  }
}

class WeatherLocation {
  const WeatherLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  final String name;
  final double latitude;
  final double longitude;
  final String timezone;

  factory WeatherLocation.fromJson(Map<String, dynamic> json) {
    return WeatherLocation(
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezone: json['timezone'] as String,
    );
  }
}

class WeatherData {
  const WeatherData({
    required this.location,
    required this.current,
    required this.hourly,
    required this.daily,
  });

  final WeatherLocation location;
  final CurrentWeather current;
  final List<HourlyForecastItem> hourly;
  final List<DailyForecastItem> daily;

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      location: WeatherLocation.fromJson(
        Map<String, dynamic>.from(json['location'] as Map),
      ),
      current: CurrentWeather.fromJson(
        Map<String, dynamic>.from(json['current'] as Map),
      ),
      hourly: (json['hourly'] as List<dynamic>? ?? const [])
          .map((item) => HourlyForecastItem.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
      daily: (json['daily'] as List<dynamic>? ?? const [])
          .map((item) => DailyForecastItem.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
    );
  }
}
