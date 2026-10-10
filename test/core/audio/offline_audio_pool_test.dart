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
}
