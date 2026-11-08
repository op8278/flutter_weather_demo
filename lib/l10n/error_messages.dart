import 'package:flutter_weather_demo/core/api/api_error.dart';
import 'package:flutter_weather_demo/core/api/codes.dart';
import 'package:flutter_weather_demo/l10n/messages.dart';

String getErrorMessage(Object error, String locale) {
  if (error is ApiError) {
    switch (error.code) {
      case ApiCode.invalidParams:
        return t(locale, 'errorInvalidParams');
      case ApiCode.locationNotFound:
        return t(locale, 'errorLocationNotFound');
      case ApiCode.upstreamFailed:
        return t(locale, 'errorUpstream');
      case ApiCode.unknown:
        if (error.message == 'Network request failed') {
          return t(locale, 'errorNetwork');
        }
        return t(locale, 'errorGeneric');
      default:
        return t(locale, 'errorGeneric');
    }
  }
  if (error is Exception) {
    final text = error.toString();
    if (text.contains('Network request failed')) {
      return t(locale, 'errorNetwork');
    }
  }
  return t(locale, 'errorGeneric');
}
