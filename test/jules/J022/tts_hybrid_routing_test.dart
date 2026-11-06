import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/tts_service.dart';
import 'package:deutsch_bilarabi/services/hybrid_audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock the flutter_tts channel
  const MethodChannel channel = MethodChannel('flutter_tts');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'isLanguageAvailable') {
        final locale = methodCall.arguments as String?;
        if (locale == 'de-DE' || locale == 'en-US') return 1;
        return 0; // Not available
      }
      if (methodCall.method == 'isLanguageInstalled') {
        final locale = methodCall.arguments as String?;
        if (locale == 'de-DE') return 1; // Installed
        return 0;
      }
      if (methodCall.method == 'setSpeechRate' ||
          methodCall.method == 'setVolume' ||
          methodCall.method == 'setPitch' ||
          methodCall.method == 'awaitSpeakCompletion' ||
          methodCall.method == 'stop' ||
          methodCall.method == 'speak') {
        return 1;
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('Unavailable engines and rare languages', (WidgetTester tester) async {
    final tts = TtsService();
    final hybrid = HybridAudioService(ttsService: tts);

    // Rare language should be rejected
    bool res1 = await hybrid.play(text: 'test', languageCode: 'zz-ZZ');
    expect(res1, isFalse);

    // Missing voice
    bool res2 = await hybrid.play(text: 'test', languageCode: 'en-US'); // Available but not installed
    expect(res2, isFalse);
  });

  testWidgets('Rapid taps and cancellation', (WidgetTester tester) async {
    final tts = TtsService();
    final hybrid = HybridAudioService(ttsService: tts);

    // Rapid taps and cancellation
    hybrid.play(text: 'test1', languageCode: 'de-DE');
    hybrid.play(text: 'test2', languageCode: 'de-DE');
    await hybrid.stop();
  });
}
