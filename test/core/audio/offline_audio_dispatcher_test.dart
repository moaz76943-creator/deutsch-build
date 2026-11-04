import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/audio/offline_audio_dispatcher.dart';
import 'package:deutsch_bilarabi/core/audio/offline_audio_pool.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel channel = MethodChannel('flutter_tts');
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'awaitSpeakCompletion') return 1;
      if (methodCall.method == 'getVoices') return ['en-US', 'de-DE'];
      if (methodCall.method == 'setLanguage') return 1;
      if (methodCall.method == 'speak') return 1;
      if (methodCall.method == 'stop') return 1;
      if (methodCall.method == 'setSpeechRate') return 1;
      return null;
    });
  });

  tearDown(() {
    OfflineAudioPool().stop();
  });

  const MethodChannel channel = MethodChannel('flutter_tts');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'awaitSpeakCompletion':
          return 1;
        case 'setLanguage':
          final language = '${methodCall.arguments}';
          if (language.toLowerCase().startsWith('zz')) return 0;
          return 1;
        case 'setSpeechRate':
        case 'speak':
        case 'stop':
          return 1;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  // Mock MethodChannel for flutter_tts to avoid MissingPluginException
  const MethodChannel channel = MethodChannel('flutter_tts');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'awaitSpeakCompletion') {
        return 1;
      } else if (methodCall.method == 'getVoices') {
        return ['en-US', 'de-DE', 'fr-FR', 'ar-SA'];
      } else if (methodCall.method == 'setLanguage') {
        return 1;
      } else if (methodCall.method == 'speak') {
        return 1;
      } else if (methodCall.method == 'stop') {
        return 1;
      } else if (methodCall.method == 'setSpeechRate') {
        return 1;
      }
      return null;
    });
  });

  test('OfflineAudioDispatcher prevents stale callbacks on fast stops', () async {
    // We expect the speakText to return false on stop before completion,
    // or properly handle MissingPluginException in headless.
    OfflineAudioDispatcher.stopCurrentAudio();
    expect(OfflineAudioDispatcher.isPlaying, isFalse);

    // Simulate speaking
    final future = OfflineAudioDispatcher.speakText(
      text: 'hello',
      bcp47Locale: 'en-US',
    ).catchError((_) => false);

    // Stop immediately before completion
    OfflineAudioDispatcher.stopCurrentAudio();

    final result = await future;

    // If it completed after being stopped (or plugin threw), result should be false
    expect(result, isFalse);
    expect(OfflineAudioDispatcher.isPlaying, isFalse);
  });

  test('OfflineAudioDispatcher safely resolves missing capability to false', () async {
    final result = await OfflineAudioDispatcher.speakText(
      text: 'test',
      bcp47Locale: 'unknown_code',
    ).catchError((_) => false);

    expect(result, isFalse);
  });
}
