import 'package:test/test.dart';
import '../../lib/src/content/pack_migration_compatibility_auditor.dart';

void main() {
  group('PackMigrationCompatibilityAuditor Unit Tests (L089)', () {
    const auditor = PackMigrationCompatibilityAuditor(supportedAppSchemaVersion: 4);

    test('Confirms backward compatibility and progress retention for legacy packs', () {
      final report = auditor.auditCompatibility(3);
      expect(report.isBackwardCompatible, isTrue);
      expect(report.retainsUserReviewProgress, isTrue);
      expect(report.requiredTransformations.length, equals(1));
    });

    test('Validates identical schema versions without transformation overhead', () {
      final report = auditor.auditCompatibility(4);
      expect(report.isBackwardCompatible, isTrue);
      expect(report.requiredTransformations, isEmpty);
    });
  });
}
