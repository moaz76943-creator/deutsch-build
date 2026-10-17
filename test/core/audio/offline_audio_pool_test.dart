import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/audio/offline_audio_pool.dart';
import 'package:deutsch_bilarabi/core/audio/offline_audio_dispatcher.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('OfflineAudioPool - Singleton and State Verification', () {
    final pool1 = OfflineAudioPool();
    final pool2 = OfflineAudioPool();
    expect(identical(pool1, pool2), isTrue);
    expect(pool1.isPlaying, isFalse);
  });

  test('OfflineAudioDispatcher - Cancellation and Stale Check', () async {
    // Fire off multiple requests rapidly
    var f1 = OfflineAudioDispatcher.speakText(text: '1', bcp47Locale: 'de-DE');
    var f2 = OfflineAudioDispatcher.speakText(text: '2', bcp47Locale: 'de-DE');
    var f3 = OfflineAudioDispatcher.speakText(text: '3', bcp47Locale: 'de-DE');

    OfflineAudioDispatcher.stopCurrentAudio();
    var res = await Future.wait([f1, f2, f3]);

    // They should have been marked as false due to stop or token replacement
    expect(res.every((r) => r == false), isTrue);
  });

  test('OfflineAudioDispatcher - Bounded queue', () async {
    OfflineAudioDispatcher.stopCurrentAudio(); // clear queue

    // Add 6 items
    List<Future<bool>> futures = [];
    for (int i = 0; i < 6; i++) {
      futures.add(OfflineAudioDispatcher.speakText(text: 'a', bcp47Locale: 'de-DE'));
    }

    // First element should have been dropped and completed with false.
    bool firstRes = await futures[0];
    expect(firstRes, false);

    OfflineAudioDispatcher.stopCurrentAudio();
  });

  test('OfflineAudioPool - Dispose lifecycle', () async {
    final pool = OfflineAudioPool();
    pool.dispose();
    // After dispose, it shouldn't throw on play
    await pool.playWord('test');
    expect(pool.isPlaying, isFalse); // It returns early
    await pool.stop();
  });
}
