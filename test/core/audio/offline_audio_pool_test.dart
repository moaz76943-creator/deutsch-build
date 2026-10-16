import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:deutsch_bilarabi/core/audio/offline_audio_pool.dart';

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

  test('OfflineAudioPool - Singleton and State Verification', () {
    final pool1 = OfflineAudioPool();
    final pool2 = OfflineAudioPool();
    expect(identical(pool1, pool2), isTrue);
    expect(pool1.isPlaying, isFalse);
  });

  test('OfflineAudioPool - AppLifecycleState.paused triggers stop()', () {
    final pool = OfflineAudioPool();
    pool.didChangeAppLifecycleState(AppLifecycleState.paused);
    expect(pool.isPlaying, isFalse);
  });

  test('OfflineAudioPool - ignores playback if voice is missing', () async {
    final pool = OfflineAudioPool();
    // ar-SA is not in the mock verified locales
    await pool.playWord('test', locale: 'ar-SA', generationToken: 1);
    expect(pool.isPlaying, isFalse);
  });
}
