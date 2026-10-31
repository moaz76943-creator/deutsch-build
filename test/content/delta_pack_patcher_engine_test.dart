import 'package:test/test.dart';
import '../../lib/src/content/delta_pack_patcher_engine.dart';

void main() {
  group('DeltaPackPatcherEngine Unit Tests (L084)', () {
    final engine = DeltaPackPatcherEngine();

    test('Verifies patch applicability matching local base version', () {
      const patch = DeltaPatch(
        baseVersion: 10,
        targetVersion: 11,
        insertedEntries: ['neues_wort'],
        updatedEntries: [],
        deletedEntryIds: [],
      );

      expect(engine.canApplyPatch(currentLocalVersion: 10, patch: patch), isTrue);
      expect(engine.canApplyPatch(currentLocalVersion: 9, patch: patch), isFalse); // Version mismatch
      expect(patch.totalOperations, equals(1));
    });

    test('Calculates bandwidth savings for delta updates (> 90%)', () {
      final savings = engine.calculateBandwidthSavings(
        fullPackSizeBytes: 40000000, // 40MB
        deltaPatchSizeBytes: 1500000, // 1.5MB delta
      );

      expect(savings, greaterThan(95.0));
    });
  });
}
