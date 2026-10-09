import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/audio/offline_audio_pool.dart';

void main() {
  group('OfflineAudioPlugPool Tests', () {
    late OfflineAudioPlugPool pool;

    setUp(() {
      pool = OfflineAudioPlugPool(maxPoolSize: 2);
    });

    tearDown(() async {
      await pool.dispose();
    });

    test('Acquires and releases player without leakage', () async {
      final player = await pool.acquirePlayer();
      expect(pool.activeCount, 1);
      expect(pool.availableCount, 0);

      await player.play('assets/audio/test.mp3');
      expect(player.isPlaying, isTrue);

      await pool.releasePlayer(player);
      expect(pool.activeCount, 0);
      expect(pool.availableCount, 1);
      expect(player.isPlaying, isFalse);
    });

    test('Reuses pooled instances', () async {
      final player1 = await pool.acquirePlayer();
      await pool.releasePlayer(player1);
      final player2 = await pool.acquirePlayer();
      expect(identical(player1, player2), isTrue);
    });

    test('Enforces max pool boundary', () async {
      await pool.acquirePlayer();
      await pool.acquirePlayer();
      expect(() => pool.acquirePlayer(), throwsStateError);
    });
  });
}
