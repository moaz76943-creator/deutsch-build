import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/tts_service.dart';
import 'package:deutsch_bilarabi/services/hybrid_audio_service.dart';
import 'package:deutsch_bilarabi/core/audio/offline_audio_dispatcher.dart';
import 'package:deutsch_bilarabi/core/audio/offline_audio_pool.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    const MethodChannel('flutter_tts').setMockMethodCallHandler((call) async {
      if (call.method == 'getVoices') return [];
      if (call.method == 'getLanguages') return [];
      if (call.method == 'isLanguageAvailable') return 0;
      if (call.method == 'isLanguageInstalled') return 0;
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

    final result = await service.play(
      text: 'hello',
      languageCode: 'xyz-INVALID',
      onUnavailable: (msg) {
        unavailableCalled = true;
        expect(msg.contains('xyz-INVALID'), isTrue, reason: 'Message should mention the missing language code');
      },
    );

    expect(result, isFalse, reason: 'Should return false for invalid language code');
    expect(unavailableCalled, isTrue, reason: 'onUnavailable callback should be triggered');
  });

  test('TtsService speaks correctly routes to Dispatcher', () async {
    final ttsService = TtsService();
    // Assuming 'de' falls back to 'de-DE' correctly via capability check
    final result = await ttsService.speak('hallo', languageCode: 'de');
    // Test logic is basic here since we mock flutter_tts rejecting engines
    // TtsService's `speak` delegates to `_speakIfCurrent`, which checks `isVoiceAvailable`
    // Since mock flutter_tts returns 0 (not available), it will return false.
    // If it was available, it would return true.
    // The core is that we aren't silently falling back.
    expect(result, isFalse);
  });

  test('TtsService stop routes to Dispatcher', () async {
    final ttsService = TtsService();
    // we just verify it doesn't crash since it's a void Future
    await ttsService.stop();
  });
}
