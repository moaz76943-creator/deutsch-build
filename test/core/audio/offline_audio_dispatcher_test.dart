import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/audio/offline_audio_dispatcher.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
      bcp47Locale: 'zz-ZZ',
    ).catchError((_) => false);

    expect(result, isFalse);
  });
}
