import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/semantic_search/semantic_drift_tracker.dart';

void main() {
  group('SemanticDriftTracker Unit Tests (N049)', () {
    final tracker = SemanticDriftTracker();

    test('Audits amelioration shift for German word toll', () {
      final record = tracker.auditDrift('toll');
      expect(record, isNotNull);
      expect(record!.driftType, equals(DriftType.amelioration));
      expect(record.contemporaryMeaning, contains('Great'));
      expect(record.archaicMeaning, contains('Mad'));
    });

    test('Guards against inappropriate slang in formal business register', () {
      final isSafeInFormal = tracker.isAppropriateForRegister('geil', isFormalContext: true);
      final isSafeInCasual = tracker.isAppropriateForRegister('geil', isFormalContext: false);

      expect(isSafeInFormal, isFalse);
      expect(isSafeInCasual, isTrue);
    });

    test('Returns null for unrecorded non-drifting vocabulary', () {
      expect(tracker.auditDrift('wasser'), isNull);
    });
  });
}
