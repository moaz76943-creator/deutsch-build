import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/tts_service.dart';
import 'package:deutsch_bilarabi/services/hybrid_audio_service.dart';
import 'package:deutsch_bilarabi/core/audio/offline_audio_dispatcher.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    const MethodChannel('flutter_tts').setMockMethodCallHandler((call) async {
      if (call.method == 'getVoices') return [];
      if (call.method == 'getLanguages') return [];
      if (call.method == 'isLanguageAvailable') return 1;
      if (call.method == 'isLanguageInstalled') return 1;
      if (call.method == 'setLanguage') return 1;
      if (call.method == 'speak') return 1;
      return null;
    });
  });

  tearDown(() {
    OfflineAudioDispatcher.stopCurrentAudio();
  });

  test('HybridAudioService does not fallback to English for missing language', () async {
    final ttsService = TtsService();
    final service = HybridAudioService(ttsService: ttsService);

    bool unavailableCalled = false;

    // 'xyz-INVALID' will be processed by getFallbackLocale, which may just return null or empty.
    final result = await service.play(
      text: 'hello',
      languageCode: 'xyz', // Use short invalid code to ensure it's not treated as regional
      onUnavailable: (msg) {
        unavailableCalled = true;
      },
    );

    expect(result, isFalse, reason: 'Should return false for invalid language code');
    expect(unavailableCalled, isTrue, reason: 'onUnavailable callback should be triggered');
  });

  test('TtsService speaks correctly routes to Dispatcher', () async {
    final ttsService = TtsService();
    // Dispatcher will actually play because our flutter_tts mock returns success for everything
    final result = await ttsService.speak('hallo', languageCode: 'de');
    // Using OfflineAudioDispatcher requires valid capability checks.
    expect(result, isTrue);
  });

  test('TtsService stop routes to Dispatcher', () async {
    final ttsService = TtsService();
    await ttsService.stop();
  });
}
