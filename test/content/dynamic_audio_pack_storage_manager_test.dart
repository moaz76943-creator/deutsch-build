import 'package:test/test.dart';
import '../../lib/src/content/dynamic_audio_pack_storage_manager.dart';

void main() {
  group('DynamicAudioPackStorageManager Unit Tests (L087)', () {
    final manager = DynamicAudioPackStorageManager();

    test('Allows ultra-lightweight text-only installation (~5MB) without heavy audio (45MB)', () {
      final textOnly = manager.calculateFootprint(
        packId: 'de_ar_b1',
        baseTextDbMb: 5.2,
        audioPackMb: 45.0,
        includeAudio: false,
      );

      expect(textOnly.isAudioDownloaded, isFalse);
      expect(textOnly.totalDiskFootprintMb, equals(5.2));

      final withAudio = manager.calculateFootprint(
        packId: 'de_ar_b1',
        baseTextDbMb: 5.2,
        audioPackMb: 45.0,
        includeAudio: true,
      );

      expect(withAudio.isAudioDownloaded, isTrue);
      expect(withAudio.totalDiskFootprintMb, equals(50.2));
    });

    test('Guards device against low-storage crashes by enforcing 250MB OS safety buffer', () {
      expect(manager.canSafelyInstallAudio(freeDiskSpaceMb: 300.0, audioPackMb: 40.0), isTrue); // 260MB left >= 250MB
      expect(manager.canSafelyInstallAudio(freeDiskSpaceMb: 260.0, audioPackMb: 40.0), isFalse); // 220MB left < 250MB
    });
  });
}
