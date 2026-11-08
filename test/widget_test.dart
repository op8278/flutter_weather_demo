import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_weather_demo/l10n/messages.dart';

void main() {
  test('i18n tables cover core keys', () {
    expect(t('en', 'citiesTitle'), 'Weather');
    expect(t('zh', 'citiesTitle'), '天气');
    expect(t('en', 'emptyFavorites'), contains('No cities yet'));
    expect(t('zh', 'retry'), '重试');
  });
}
