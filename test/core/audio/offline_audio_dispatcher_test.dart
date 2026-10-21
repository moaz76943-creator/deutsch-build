import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/audio/offline_audio_dispatcher.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel channel = MethodChannel('flutter_tts');
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'awaitSpeakCompletion') return 1;
      if (methodCall.method == 'stop') return 1;
      if (methodCall.method == 'setLanguage') {
        final lang = methodCall.arguments as String;
        if (lang == 'zz-ZZ') return 0;
        return 1;
      }
      if (methodCall.method == 'speak') return 1;
      return null;
    });
  });

  test('OfflineAudioDispatcher prevents stale callbacks on fast stops', () async {
    OfflineAudioDispatcher.stopCurrentAudio();
    expect(OfflineAudioDispatcher.isPlaying, isFalse);

    final future = OfflineAudioDispatcher.speakText(
      text: 'hello',
      bcp47Locale: 'en-US',
    ).catchError((_) => false);

    OfflineAudioDispatcher.stopCurrentAudio();

    final result = await future;
    expect(result, isFalse);
    expect(OfflineAudioDispatcher.isPlaying, isFalse);
  });

  test('OfflineAudioDispatcher safely resolves missing capability to false', () async {
    final result = await OfflineAudioDispatcher.speakText(
      text: 'test',
      bcp47Locale: 'zz-ZZ',
    ).catchError((_) => false);

    expect(result, isFalse);
  });
}
