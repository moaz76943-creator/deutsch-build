import 'package:deutsch_bilarabi/services/language_pack_manager.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pack selection cannot be inferred from available text-to-speech locales.
void main() {
  test('default BCP-47 TTS locale maps to the base content identity', () {
    expect(LanguagePackManager.resolveContentLanguageCode('de-DE'), 'de');
    expect(LanguagePackManager.resolveContentLanguageCode('ar-SA'), 'ar');
    expect(LanguagePackManager.resolveContentLanguageCode('en'), 'en');
  });

  test('explicit scripts and nondefault regions retain their identity', () {
    expect(
      LanguagePackManager.resolveContentLanguageCode('zh-Hant'),
      'zh-hant',
    );
    expect(
      LanguagePackManager.resolveContentLanguageCode('ar-EG'),
      'ar-eg',
    );
    expect(
      LanguagePackManager.resolveContentLanguageCode('de-AT'),
      'de-at',
    );
  });

  test('unsupported or malformed tags are not silently mapped to German', () {
    expect(LanguagePackManager.resolveContentLanguageCode('zz-ZZ'), isNull);
    expect(LanguagePackManager.resolveContentLanguageCode('../de'), isNull);
    expect(LanguagePackManager.resolveContentLanguageCode(''), isNull);
  });

  test('unregistered pack is not declared mounted', () async {
    expect(await LanguagePackManager.verifyAndMountOfflinePack('zz-ZZ'), isFalse);
  });
}
