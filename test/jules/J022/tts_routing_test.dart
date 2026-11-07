import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/tts_service.dart';
import 'package:deutsch_bilarabi/services/hybrid_audio_service.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  bool isAvailable = true;

  setUp(() {
    isAvailable = true;
    const MethodChannel channel = MethodChannel('flutter_tts');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'awaitSpeakCompletion') return 1;
      if (methodCall.method == 'setLanguage') return isAvailable ? 1 : 0;
      if (methodCall.method == 'isLanguageAvailable') return isAvailable ? 1 : 0;
      if (methodCall.method == 'isLanguageInstalled') return isAvailable ? 1 : 0;
      if (methodCall.method == 'speak') return 1;
      if (methodCall.method == 'stop') return 1;
      if (methodCall.method == 'setSpeechRate') return 1;
      if (methodCall.method == 'setVolume') return 1;
      if (methodCall.method == 'setPitch') return 1;
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), null);
  });

  test('TtsService uses OfflineAudioCapability for missing locale rejection', () async {
    final tts = TtsService();
    final result = await tts.speak('test', languageCode: 'zz-ZZ');
    expect(result, isFalse);
    expect(tts.status, TtsStatus.unsupportedLanguage);
  });

  test('HybridAudioService handles unavailable engines gracefully', () async {
    isAvailable = false;
    final hybrid = HybridAudioService();

    String? capturedMessage;
    final result = await hybrid.play(
      text: 'Hello',
      languageCode: 'en',
      onUnavailable: (msg) {
        capturedMessage = msg;
      }
    );

    expect(result, isFalse);
    expect(capturedMessage, contains('Audio not available for'));
  });

  test('HybridAudioService playback successfully delegates to offline dispatcher', () async {
    final hybrid = HybridAudioService();
    // In our mock, OfflineAudioDispatcher (via OfflineAudioPool) uses flutter_tts under the hood
    // but the success routing works properly through TtsService speak
    final result = await hybrid.play(text: 'Hello', languageCode: 'en');
    expect(result, isTrue);
  });

  test('TtsService stop calls stop correctly on all audio systems', () async {
    final tts = TtsService();
    await tts.speak('Test', languageCode: 'en');
    await tts.stop();
    expect(tts.status, TtsStatus.stopped);
  });
}
