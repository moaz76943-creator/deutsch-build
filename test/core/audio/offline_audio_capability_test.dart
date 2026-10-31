import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/audio/offline_audio_capability.dart';

void main() {
  group('OfflineAudioCapability Tests', () {
    test('Returns explicit regional fallback for 100 language codes', () {
      expect(OfflineAudioCapability.getFallbackLocale('en'), 'en-US');
      expect(OfflineAudioCapability.getFallbackLocale('de'), 'de-DE');
      expect(OfflineAudioCapability.getFallbackLocale('ar'), 'ar-SA');
      expect(OfflineAudioCapability.getFallbackLocale('ja'), 'ja-JP');
      expect(OfflineAudioCapability.getFallbackLocale('unknown_code'), null);
    });

    test('Returns exact mapping if already explicitly regional', () {
      expect(OfflineAudioCapability.getFallbackLocale('es-MX'), 'es-MX');
      expect(OfflineAudioCapability.getFallbackLocale('en-GB'), 'en-GB');
    });

    test('Never falls back silently to English or German', () {
      expect(OfflineAudioCapability.getFallbackLocale('fr'), isNot('en-US'));
      expect(OfflineAudioCapability.getFallbackLocale('fr'), isNot('de-DE'));
      expect(OfflineAudioCapability.getFallbackLocale('fr'), 'fr-FR');

      expect(OfflineAudioCapability.getFallbackLocale('invalid'), null);
    });
  });
}
