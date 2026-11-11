import 'package:test/test.dart';
import 'package:deutsch_build/src/core/content/german_gerundive_apposition_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave29_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4929 Gerundive Apposition Engine Tests', () {
    test('LING-052: Gerundiv constructs zu lösendes Problem with obligation equivalence', () {
      final res = GermanGerundiveAppositionEngine.buildGerundive(
        article: 'das',
        noun: 'Problem',
        verbInfinitive: 'lösen',
        partizipTwo: 'gelöst',
        adjectiveEnding: 'e',
        modalSense: GerundiveModalSense.obligationMuss,
      );

      expect(res.gerundivePhrase, equals('das zu lösende Problem'));
      expect(res.equivalentRelativeClause, equals('das Problem, das gelöst werden muss'));
      expect(res.arabicEquivalence, contains('حتمية ووجوب الفعل'));
    });

    test('LING-052: Gerundiv with possibility constructs kann equivalent', () {
      final res = GermanGerundiveAppositionEngine.buildGerundive(
        article: 'die',
        noun: 'Aufgabe',
        verbInfinitive: 'bewältigen',
        partizipTwo: 'bewältigt',
        adjectiveEnding: 'e',
        modalSense: GerundiveModalSense.possibilityKann,
      );

      expect(res.gerundivePhrase, equals('die zu bewältigende Aufgabe'));
      expect(res.equivalentRelativeClause, equals('die Aufgabe, die bewältigt werden kann'));
    });

    test('UI Bridge generates accurate Task 4929 diagnostics report', () {
      final bridge = Vol116Wave29UIBridge();
      final report = bridge.getTask4929Diagnostics();

      expect(report['task_id'], equals(4929));
      expect(report['volume'], equals(116));
      expect(report['tasks_remaining_to_5000'], equals(71));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
