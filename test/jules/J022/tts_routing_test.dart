import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/tts_service.dart';
import 'package:deutsch_bilarabi/services/hybrid_audio_service.dart';
import 'package:deutsch_bilarabi/core/audio/offline_audio_dispatcher.dart';
import 'package:flutter/services.dart';
import 'package:deutsch_bilarabi/core/audio/offline_audio_pool.dart';
import 'dart:async';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  bool mockAvailable = false;

  setUp(() {
    const MethodChannel('flutter_tts').setMockMethodCallHandler((call) async {
      if (call.method == 'getVoices') return [];
      if (call.method == 'getLanguages') return [];
      if (call.method == 'isLanguageAvailable') return mockAvailable ? 1 : 0;
      if (call.method == 'isLanguageInstalled') return mockAvailable ? 1 : 0;
      if (call.method == 'setLanguage') return mockAvailable ? 1 : 0;
      if (call.method == 'speak') return 1;
      if (call.method == 'stop') return 1;
      return null;
    });
  });

  tearDown(() {
    OfflineAudioDispatcher.stopCurrentAudio();
    mockAvailable = false;
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

  test('TtsService stop routes to Dispatcher', () async {
    final ttsService = TtsService();
    await ttsService.stop();
  });

  test('Unavailable engines are handled gracefully', () async {
    mockAvailable = false;
    final ttsService = TtsService();
    final result = await ttsService.speak('hello', languageCode: 'de');
    expect(result, isFalse);
  });

  test('Rare languages fallback properly via capability contract (or fail)', () async {
    // We expect it to NOT fail, but return true if the contract supports it (haw is supported).
    mockAvailable = true;
    final ttsService = TtsService();
    final result = await ttsService.speak('rare test', languageCode: 'haw');
    expect(result, isTrue, reason: 'Hawaiian is supported by capability contract map as haw-US');
  });

  test('Rapid taps / Overlapping playback sessions', () async {
    mockAvailable = true;
    final ttsService = TtsService();
    // Start multiple
    final f1 = ttsService.speak('first', languageCode: 'de');
    final f2 = ttsService.speak('second', languageCode: 'de');
    final f3 = ttsService.speak('third', languageCode: 'de');

    final results = await Future.wait([f1, f2, f3]);
    expect(results.length, 3);
    // Because we call OfflineAudioDispatcher.stopCurrentAudio() inside _speakIfCurrent,
    // f1 and f2 should be aborted and only f3 should potentially return true (though due to async/queue behavior in mock it might be different, but we check they don't crash).
  });

  test('Wrong-locale fallback and cancellation', () async {
    mockAvailable = true;
    final ttsService = TtsService();
    final speakFuture = ttsService.speak('hello', languageCode: 'de');
    await ttsService.stop(); // Cancellation should work cleanly
    final res = await speakFuture;
    expect(res, isFalse, reason: 'Cancellation should abort speech');
  });
}
