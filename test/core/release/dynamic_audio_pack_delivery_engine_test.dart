import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/release/dynamic_audio_pack_delivery_engine.dart';

void main() {
  group('DynamicAudioPackDeliveryEngine Tests', () {
    test('Initial bundled audio is strictly compact under 5MB', () {
      final engine = DynamicAudioPackDeliveryEngine();
      final initialMb = engine.computeDownloadedStorageMb();

      expect(initialMb, lessThan(5.0));
      expect(initialMb, greaterThan(3.0));
    });

    test('Installs audio pack with valid checksum and marks as downloaded', () {
      final engine = DynamicAudioPackDeliveryEngine();

      final success = engine.installAudioPack('de_a1_highres', 'sha256_de_a1_highres');
      expect(success, isTrue);

      final updatedMb = engine.computeDownloadedStorageMb();
      expect(updatedMb, greaterThan(15.0));
    });

    test('Rejects installation on invalid checksum', () {
      final engine = DynamicAudioPackDeliveryEngine();
      final success = engine.installAudioPack('de_a1_highres', 'invalid_corrupt_hash');
      expect(success, isFalse);
    });

    test('Automatically prunes least recently used audio packs when storage budget is reached', () {
      final engine = DynamicAudioPackDeliveryEngine(maxAllowedStorageMb: 40.0);

      engine.installAudioPack('de_a1_highres', 'sha256_de_a1_highres');
      engine.installAudioPack('de_b1_conversational', 'sha256_de_b1_conversational');

      // Now attempting to install 34MB Piper voice will exceed 40MB budget and trigger LRU eviction
      final success = engine.installAudioPack('piper_neural_voice_thorsten', 'sha256_piper_neural_thorsten');
      expect(success, isTrue);

      // Core starter pack is preserved, while older packs are pruned
      expect(engine.listAvailablePacks().firstWhere((p) => p.packId == 'core_starter_pack').isDownloaded, isTrue);
      expect(engine.computeDownloadedStorageMb(), lessThanOrEqualTo(40.0));
    });
  });
}
