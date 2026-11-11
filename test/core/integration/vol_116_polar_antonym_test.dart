import 'package:test/test.dart';
import 'package:deutsch_build/src/core/content/german_polar_antonym_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave23_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4923 Polar Antonym Engine Tests', () {
    test('LING-046: steigen and sinken matched with price/trend domain', () {
      final pair = GermanPolarAntonymEngine.findPair('steigen');
      expect(pair, isNotNull);
      expect(pair!.negativeTerm, equals('sinken'));
      expect(pair.domain, equals(AntonymDomain.trendsQuantity));
      expect(pair.arabicEquivalence, contains('يرتفع'));
    });

    test('LING-046: Improper collocation *Preise nehmen zu flagged critically', () {
      final warning = GermanPolarAntonymEngine.auditSubjectVerbPairing('Die Preise', 'nehmen zu');
      expect(warning, isNotNull);
      expect(warning, contains('Die Preise steigen'));
    });

    test('LING-046: Proper collocation Die Preise steigen passes cleanly', () {
      final warning = GermanPolarAntonymEngine.auditSubjectVerbPairing('Die Preise', 'steigen');
      expect(warning, isNull);
    });

    test('UI Bridge generates accurate Task 4923 diagnostics report', () {
      final bridge = Vol116Wave23UIBridge();
      final report = bridge.getTask4923Diagnostics();

      expect(report['task_id'], equals(4923));
      expect(report['volume'], equals(116));
      expect(report['tasks_remaining_to_5000'], equals(77));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
