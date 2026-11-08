/// Production Vercel API by default.
/// Override for Simulator when macOS system proxy is unavailable:
///   `flutter run --dart-define=API_BASE=http://192.168.x.x:8787`
const String apiBase = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'https://next-weather-demo.vercel.app',
);

String get normalizedApiBase {
  if (apiBase.endsWith('/')) {
    return apiBase.substring(0, apiBase.length - 1);
  }
  return apiBase;
}
