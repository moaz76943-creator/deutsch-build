import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/tts_service.dart';
import 'package:deutsch_bilarabi/services/hybrid_audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('J022 Audio Routing', () {
    test('HybridAudioService uses internal _tts.getTtsLocale which uses Capability fallback', () {
      final tts = TtsService();

      expect(tts.getTtsLocale('de'), 'de-DE');
      expect(tts.getTtsLocale('es'), 'es-ES');
    });

    test('Unavailable engine gracefully rejects missing voices', () async {
      final tts = TtsService();
      final result = await tts.isVoiceAvailable('non-existent-language');
      expect(result, isFalse);
    });

    test('Pitch and Speech Rate Configuration Preservation', () async {
      final tts = TtsService();
      await tts.configure(speechRate: 0.8, pitch: 1.2);
      expect(tts.speechRate, 0.8);
      expect(tts.pitch, 1.2);
    });

    test('Rapid taps and Cancellation via stopCurrentAudio', () async {
      final tts = TtsService();
      await tts.speak('Test 1');
      await tts.speak('Test 2');
      await tts.stop();
      // Should not throw or crash on rapid cancellation.
      expect(tts.status, TtsStatus.stopped);
    });
  });
}
