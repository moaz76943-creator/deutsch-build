import 'package:deutsch_bilarabi/features/audio/data/android_recorded_audio_player.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('recorded player sends only safe local asset paths', () async {
    const channel = MethodChannel(
      'com.deutschbilarabi.app/recorded_audio_player',
    );
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    String? received;
    messenger.setMockMethodCallHandler(channel, (call) async {
      received = (call.arguments as Map<Object?, Object?>)['assetPath']
          ?.toString();
      return true;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

    final player = AndroidRecordedAudioPlayer(channel: channel);

    expect(
      await player.playAsset('content/german/audio/de-1.mp3'),
      isTrue,
    );
    expect(received, 'content/german/audio/de-1.mp3');
    expect(await player.playAsset('../secret.mp3'), isFalse);
  });

  test('missing Android bridge fails closed to TTS fallback', () async {
    const channel = MethodChannel(
      'com.deutschbilarabi.app/recorded_audio_player_missing',
    );
    final player = AndroidRecordedAudioPlayer(channel: channel);

    expect(
      await player.playAsset('content/german/audio/de-1.mp3'),
      isFalse,
    );
  });
}
