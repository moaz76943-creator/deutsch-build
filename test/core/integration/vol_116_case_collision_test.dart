import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/content/german_case_collision_auditor.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave18_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4918 Case Collision & UI Auditor Tests', () {
    test('LING-041: Critical collision flagged when Dative and Accusative verbs share an object', () {
      final report = GermanCaseCollisionAuditor.auditVerbCoordination(
        firstVerb: 'helfen',
        secondVerb: 'unterstützen',
        sharedObjectPronoun: 'dich',
      );

      expect(report.severity, equals(AuditSeverity.criticalError));
      expect(report.collisionType, equals(CollisionCategory.rektionskollisionCaseConflict));
      expect(report.diagnosticFinding, contains('Rektionskollision'));
      expect(report.sovereignCorrection, contains('Ich helfe dir'));
    });

    test('LING-041: Clean verification when coordinated verbs share compatible case', () {
      final report = GermanCaseCollisionAuditor.auditVerbCoordination(
        firstVerb: 'sehen',
        secondVerb: 'unterstützen',
        sharedObjectPronoun: 'dich',
      );

      expect(report.severity, equals(AuditSeverity.cleanVerified));
      expect(report.collisionType, isNull);
    });

    test('LING-041: UI layout auditor detects bidirectional text overflow hazard', () {
      final layoutReport = GermanCaseCollisionAuditor.auditBilingualUiLayout(
        germanText: 'Das ist eine sehr lange deutsche Erklärung für den Fall',
        arabicText: 'هذا شرح عربي طويل ومفصل يتجاوز الحاوية البصرية',
        maxContainerWidthChars: 60,
      );

      expect(layoutReport.severity, equals(AuditSeverity.warningNotice));
      expect(layoutReport.collisionType, equals(CollisionCategory.textLayoutRtlLtrOverflow));
    });

    test('UI Bridge generates accurate Task 4918 diagnostics report', () {
      final bridge = Vol116Wave18UIBridge();
      final report = bridge.getTask4918Diagnostics();

      expect(report['task_id'], equals(4918));
      expect(report['volume'], equals(116));
      expect(report['audit_mode'], equals('STRICT_CRITICAL_ZERO_COMPROMISE'));
      expect(report['tasks_remaining_to_5000'], equals(82));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
