import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/audio/offline_audio_dispatcher.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    const MethodChannel('flutter_tts').setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getVoices') {
        return [
          {'name': 'de-DE-default', 'locale': 'de-DE'},
          {'name': 'en-US-default', 'locale': 'en-US'},
        ];
      }
      if (methodCall.method == 'getLanguages') {
        return ['de-DE', 'en-US'];
      }
      if (methodCall.method == 'stop') {
        return 1;
      }
      return null;
    });
  });

  test('OfflineAudioDispatcher - stopCurrentAudio triggers cancellation', () {
    OfflineAudioDispatcher.speakText(text: 'test', bcp47Locale: 'de-DE');
    expect(OfflineAudioDispatcher.isPlaying, isTrue);
    OfflineAudioDispatcher.stopCurrentAudio();
    expect(OfflineAudioDispatcher.isPlaying, isFalse);
  });
}
