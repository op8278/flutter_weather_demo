enum WeatherMood { clear, cloudy, fog, rain, snow, storm }

enum WeatherIconKind {
  clear,
  mainlyClear,
  partlyCloudy,
  overcast,
  fog,
  drizzle,
  rain,
  freezingRain,
  snow,
  showers,
  snowShowers,
  thunderstorm,
  unknown,
}

const Map<int, ({String en, String zh})> _weatherDescriptions = {
  0: (en: 'Clear', zh: '晴'),
  1: (en: 'Mainly clear', zh: '大部晴朗'),
  2: (en: 'Partly cloudy', zh: '局部多云'),
  3: (en: 'Overcast', zh: '阴'),
  45: (en: 'Fog', zh: '雾'),
  48: (en: 'Depositing rime fog', zh: '霜雾'),
  51: (en: 'Light drizzle', zh: '小毛毛雨'),
  53: (en: 'Drizzle', zh: '毛毛雨'),
  55: (en: 'Dense drizzle', zh: '浓毛毛雨'),
  56: (en: 'Light freezing drizzle', zh: '轻度冻毛毛雨'),
  57: (en: 'Freezing drizzle', zh: '冻毛毛雨'),
  61: (en: 'Slight rain', zh: '小雨'),
  63: (en: 'Rain', zh: '中雨'),
  65: (en: 'Heavy rain', zh: '大雨'),
  66: (en: 'Light freezing rain', zh: '轻度冻雨'),
  67: (en: 'Freezing rain', zh: '冻雨'),
  71: (en: 'Slight snow', zh: '小雪'),
  73: (en: 'Snow', zh: '中雪'),
  75: (en: 'Heavy snow', zh: '大雪'),
  77: (en: 'Snow grains', zh: '雪粒'),
  80: (en: 'Slight rain showers', zh: '小阵雨'),
  81: (en: 'Rain showers', zh: '阵雨'),
  82: (en: 'Violent rain showers', zh: '强阵雨'),
  85: (en: 'Slight snow showers', zh: '小阵雪'),
  86: (en: 'Heavy snow showers', zh: '强阵雪'),
  95: (en: 'Thunderstorm', zh: '雷暴'),
  96: (en: 'Thunderstorm with hail', zh: '雷暴伴冰雹'),
  99: (en: 'Thunderstorm with heavy hail', zh: '强雷暴伴冰雹'),
};

String getWeatherDescription(int code, String locale) {
  final entry = _weatherDescriptions[code];
  if (entry == null) {
    return locale == 'zh' ? '未知' : 'Unknown';
  }
  return locale == 'zh' ? entry.zh : entry.en;
}

WeatherIconKind getWeatherIconKind(int code) {
  if (code == 0) return WeatherIconKind.clear;
  if (code == 1) return WeatherIconKind.mainlyClear;
  if (code == 2) return WeatherIconKind.partlyCloudy;
  if (code == 3) return WeatherIconKind.overcast;
  if (code == 45 || code == 48) return WeatherIconKind.fog;
  if (code >= 51 && code <= 57) return WeatherIconKind.drizzle;
  if (code == 66 || code == 67) return WeatherIconKind.freezingRain;
  if (code >= 61 && code <= 65) return WeatherIconKind.rain;
  if (code >= 80 && code <= 82) return WeatherIconKind.showers;
  if (code >= 71 && code <= 77) return WeatherIconKind.snow;
  if (code == 85 || code == 86) return WeatherIconKind.snowShowers;
  if (code >= 95) return WeatherIconKind.thunderstorm;
  return WeatherIconKind.unknown;
}

WeatherMood getWeatherMood(int code) {
  if (code == 0 || code == 1) return WeatherMood.clear;
  if (code == 2 || code == 3) return WeatherMood.cloudy;
  if (code == 45 || code == 48) return WeatherMood.fog;
  if (code >= 71 && code <= 77) return WeatherMood.snow;
  if (code >= 85 && code <= 86) return WeatherMood.snow;
  if (code >= 95) return WeatherMood.storm;
  return WeatherMood.rain;
}

List<ColorStop> getBackgroundColors(WeatherMood mood, bool isDay) {
  if (!isDay) {
    switch (mood) {
      case WeatherMood.clear:
        return const [
          ColorStop(0xFF1a2744, 0),
          ColorStop(0xFF0d1526, 0.55),
          ColorStop(0xFF0a1020, 1),
        ];
      case WeatherMood.cloudy:
        return const [
          ColorStop(0xFF2a3344, 0),
          ColorStop(0xFF161c28, 0.55),
          ColorStop(0xFF0f141d, 1),
        ];
      case WeatherMood.fog:
        return const [
          ColorStop(0xFF3a4250, 0),
          ColorStop(0xFF1e2430, 0.55),
          ColorStop(0xFF141820, 1),
        ];
      case WeatherMood.snow:
        return const [
          ColorStop(0xFF2c3a4e, 0),
          ColorStop(0xFF1a2433, 0.55),
          ColorStop(0xFF121820, 1),
        ];
      case WeatherMood.storm:
        return const [
          ColorStop(0xFF1f2433, 0),
          ColorStop(0xFF12161f, 0.55),
          ColorStop(0xFF0b0e14, 1),
        ];
      case WeatherMood.rain:
        return const [
          ColorStop(0xFF243044, 0),
          ColorStop(0xFF141c2a, 0.55),
          ColorStop(0xFF0e1420, 1),
        ];
    }
  }

  switch (mood) {
    case WeatherMood.clear:
      return const [
        ColorStop(0xFF5b8fd6, 0),
        ColorStop(0xFF7eabdf, 0.4),
        ColorStop(0xFFa8c5e8, 1),
      ];
    case WeatherMood.cloudy:
      return const [
        ColorStop(0xFF7a8ea3, 0),
        ColorStop(0xFF93a4b5, 0.45),
        ColorStop(0xFFb0bdc9, 1),
      ];
    case WeatherMood.fog:
      return const [
        ColorStop(0xFF9aa6b2, 0),
        ColorStop(0xFFb0b8c0, 0.5),
        ColorStop(0xFFc4cad0, 1),
      ];
    case WeatherMood.snow:
      return const [
        ColorStop(0xFF8fa3b8, 0),
        ColorStop(0xFFa8b8c8, 0.45),
        ColorStop(0xFFc5d0da, 1),
      ];
    case WeatherMood.storm:
      return const [
        ColorStop(0xFF4a5568, 0),
        ColorStop(0xFF5c6878, 0.45),
        ColorStop(0xFF748090, 1),
      ];
    case WeatherMood.rain:
      return const [
        ColorStop(0xFF5f7a96, 0),
        ColorStop(0xFF7a92a8, 0.45),
        ColorStop(0xFF9aafc0, 1),
      ];
  }
}

class ColorStop {
  const ColorStop(this.argb, this.stop);

  final int argb;
  final double stop;
}
