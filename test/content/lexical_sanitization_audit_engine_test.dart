import 'package:test/test.dart';
import '../../lib/src/content/lexical_sanitization_audit_engine.dart';

void main() {
  group('LexicalSanitizationAuditEngine Unit Tests (L090)', () {
    final engine = LexicalSanitizationAuditEngine();

    test('Validates clean educational vocabulary passing all ethical tests', () {
      final cleanWords = ['wasser', 'brot', 'lernen', 'arbeiten', 'gesundheit', 'familie'];
      final report = engine.auditVocabulary(cleanWords, targetLocale: 'de');

      expect(report.isEthicallyPure, isTrue);
      expect(report.isProhibitedLocalesExcluded, isTrue);
      expect(report.flaggedViolations, isEmpty);
      expect(report.totalScannedWords, equals(6));
    });

    test('Detects and flags forbidden substances immediately', () {
      final taintedWords = ['wasser', 'rotwein', 'brot'];
      final report = engine.auditVocabulary(taintedWords, targetLocale: 'de');

      expect(report.isEthicallyPure, isFalse);
      expect(report.flaggedViolations.first, contains('wein'));
    });

    test('Strictly rejects prohibited language codes', () {
      final report = engine.auditVocabulary(['wort'], targetLocale: 'he');
      expect(report.isProhibitedLocalesExcluded, isFalse);
      expect(report.flaggedViolations.any((f) => f.contains('Prohibited language code')), isTrue);
    });
  });
}
