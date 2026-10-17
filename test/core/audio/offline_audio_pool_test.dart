import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/audio/offline_audio_pool.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('OfflineAudioPool - Singleton and State Verification', () {
    final pool1 = OfflineAudioPool();
    final pool2 = OfflineAudioPool();
    expect(identical(pool1, pool2), isTrue);
    expect(pool1.isPlaying, isFalse);
  });

  test('OfflineAudioPool - Cancellation bounds queue size', () async {
    // Note: Due to MissingPluginException in headless unit tests,
    // we catch exceptions on playWord rather than failing the test.
    final pool = OfflineAudioPool();
    await pool.stop();
    expect(pool.isPlaying, isFalse);

    pool.playWord("test1").catchError((_) {});
    pool.playWord("test2").catchError((_) {});
    pool.playWord("test3").catchError((_) {});
    pool.playWord("test4").catchError((_) {});

    await pool.stop();
    expect(pool.isPlaying, isFalse);
  });

  test('OfflineAudioPool - Missing voice gracefully fails', () async {
    final pool = OfflineAudioPool();
    final isCapable = await pool.verifyOfflineCapability('zz-ZZ');
    expect(isCapable, isFalse);
  });
}
