import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/tts_service.dart';
import 'package:deutsch_bilarabi/services/hybrid_audio_service.dart';
import 'package:deutsch_bilarabi/core/audio/offline_audio_dispatcher.dart';
import 'package:deutsch_bilarabi/core/audio/offline_audio_capability.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    const MethodChannel channel = MethodChannel('flutter_tts');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        if (methodCall.method == 'awaitSpeakCompletion') return 1;
        if (methodCall.method == 'getVoices') return [];
        if (methodCall.method == 'getLanguages') return ['de-DE', 'ar-SA', 'en-US'];
        if (methodCall.method == 'setLanguage') return 1;
        if (methodCall.method == 'setSpeechRate') return 1;
        if (methodCall.method == 'setVolume') return 1;
        if (methodCall.method == 'setPitch') return 1;
        if (methodCall.method == 'isLanguageAvailable') {
          return (methodCall.arguments as String) == 'de-DE' || (methodCall.arguments as String) == 'ar-SA' ? 1 : 0;
        }
        if (methodCall.method == 'isLanguageInstalled') {
          return (methodCall.arguments as String) == 'de-DE' || (methodCall.arguments as String) == 'ar-SA' ? 1 : 0;
        }
        if (methodCall.method == 'speak') return 1;
        if (methodCall.method == 'stop') return 1;
        return null;
      },
    );
  });

  group('J022 TTS Routing & Offline Voice Recovery', () {
    late TtsService ttsService;
    late HybridAudioService hybridService;

    setUp(() {
      ttsService = TtsService(speechRate: 0.5);
      hybridService = HybridAudioService(
        ttsService: ttsService,
        voiceTimeout: const Duration(milliseconds: 100),
        playbackTimeout: const Duration(milliseconds: 100),
        voiceProbe: (tag) async => tag == 'de-DE' || tag == 'ar-SA',
        speechPlayback: (text, tag) async {
          if (tag == 'de-DE' || tag == 'ar-SA') {
             await Future.delayed(const Duration(milliseconds: 10));
             return true;
          }
          return false;
        },
      );
    });

    tearDown(() async {
      await ttsService.dispose();
      await hybridService.dispose();
    });

    test('1. TtsService uses correct fallback locale', () {
      expect(ttsService.getTtsLocale('de'), 'de-DE');
      expect(ttsService.getTtsLocale('de-DE'), 'de-DE');
      expect(ttsService.getTtsLocale('ar'), 'ar-SA');
      expect(ttsService.getTtsLocale('xyz'), isEmpty);
    });

    test('2. TtsService speak routes through dispatcher correctly', () async {
      List<TtsStatus> statuses = [];
      ttsService.onStatus = (status, {locale, message}) {
        statuses.add(status);
      };

      final result = await ttsService.speak('hallo', languageCode: 'de');

      expect(result, isTrue);
      expect(statuses, contains(TtsStatus.speaking));
      expect(statuses, contains(TtsStatus.completed));
    });

    test('3. HybridAudioService unavailable engines & wrong-locale fallback', () async {
      bool unavailableCalled = false;
      final result = await hybridService.play(
        text: 'test',
        languageCode: 'xyz', // invalid
        onUnavailable: (msg) {
          unavailableCalled = true;
          expect(msg, contains('xyz'));
        },
      );

      expect(result, isFalse);
      expect(unavailableCalled, isTrue);
    });

    test('4. HybridAudioService rare languages unsupported', () async {
      bool unavailableCalled = false;
      final result = await hybridService.play(
        text: 'test',
        languageCode: 'zu', // valid BCP-47 but simulated as not installed by voiceProbe
        onUnavailable: (msg) {
          unavailableCalled = true;
          expect(msg, contains('zu'));
        },
      );

      expect(result, isFalse);
      expect(unavailableCalled, isTrue);
    });

    test('5. HybridAudioService success for supported language', () async {
      bool unavailableCalled = false;
      final result = await hybridService.play(
        text: 'test',
        languageCode: 'de',
        onUnavailable: (msg) {
          unavailableCalled = true;
        },
      );

      expect(result, isTrue);
      expect(unavailableCalled, isFalse);
    });

    test('6. TtsService cancellation', () async {
      List<TtsStatus> statuses = [];
      ttsService.onStatus = (status, {locale, message}) {
        statuses.add(status);
      };

      await ttsService.stop();
      expect(statuses, contains(TtsStatus.stopped));
    });

    test('7. HybridAudioService rapid taps', () async {
      int successCount = 0;

      final results = await Future.wait([
        hybridService.play(text: 'test1', languageCode: 'de'),
        hybridService.play(text: 'test2', languageCode: 'de'),
        hybridService.play(text: 'test3', languageCode: 'de'),
      ]);

      for (var r in results) {
        if (r) successCount++;
      }

      expect(successCount, 1);
    });
  });
}
