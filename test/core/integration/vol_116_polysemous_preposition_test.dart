import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/content/german_polysemous_preposition_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave28_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4928 Polysemous Preposition Engine Tests', () {
    test('LING-051: aus disambiguated for conscious internal motives', () {
      expect(GermanPolysemousPrepositionEngine.disambiguateAusVsVor('Liebe'), equals('aus'));
      expect(GermanPolysemousPrepositionEngine.disambiguateAusVsVor('Höflichkeit'), equals('aus'));
      expect(GermanPolysemousPrepositionEngine.disambiguateAusVsVor('Mitleid'), equals('aus'));
    });

    test('LING-051: vor disambiguated for involuntary emotional/physical reactions', () {
      expect(GermanPolysemousPrepositionEngine.disambiguateAusVsVor('Kälte'), equals('vor'));
      expect(GermanPolysemousPrepositionEngine.disambiguateAusVsVor('Angst'), equals('vor'));
      expect(GermanPolysemousPrepositionEngine.disambiguateAusVsVor('Schmerz'), equals('vor'));
    });

    test('LING-051: Registry contains verified polysemous extensions for an and auf', () {
      final anNuances = GermanPolysemousPrepositionEngine.getNuances('an');
      expect(anNuances.isNotEmpty, isTrue);
      expect(anNuances.first.domain, equals(PrepositionalSemanticDomain.quantitativeApproximation));

      final aufNuances = GermanPolysemousPrepositionEngine.getNuances('auf');
      expect(aufNuances.first.domain, equals(PrepositionalSemanticDomain.mannerMethod));
    });

    test('UI Bridge generates accurate Task 4928 diagnostics report', () {
      final bridge = Vol116Wave28UIBridge();
      final report = bridge.getTask4928Diagnostics();

      expect(report['task_id'], equals(4928));
      expect(report['volume'], equals(116));
      expect(report['tasks_remaining_to_5000'], equals(72));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
