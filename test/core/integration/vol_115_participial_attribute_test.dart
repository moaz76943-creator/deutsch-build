import 'package:test/test.dart';
import 'package:deutsch_build/src/core/content/german_participial_attribute_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_115_wave8_ui_bridge.dart';

void main() {
  group('Volume 115 Task 4894 Participial Attribute Engine Tests', () {
    test('LING-017: Partizip I constructs active simultaneous modifier accurately', () {
      final analysis = GermanParticipialAttributeEngine.buildPartizipOne(
        article: 'Das',
        noun: 'Kind',
        verbInfinitive: 'schlafen',
        ending: 'e',
      );

      expect(analysis.adjectivalParticiple, equals('schlafende'));
      expect(analysis.nounPhrase, equals('Das schlafende Kind'));
      expect(analysis.equivalentRelativeClause, contains('schlaft'));
    });

    test('LING-017: Partizip II constructs completed passive modifier accurately', () {
      final analysis = GermanParticipialAttributeEngine.buildPartizipTwo(
        article: 'Das',
        noun: 'Buch',
        verbInfinitive: 'lesen',
        partizipTwoRoot: 'gelesen',
        ending: 'e',
      );

      expect(analysis.adjectivalParticiple, equals('gelesene'));
      expect(analysis.nounPhrase, equals('Das gelesene Buch'));
      expect(analysis.equivalentRelativeClause, equals('Das Buch, das gelesen wurde'));
    });

    test('UI Bridge generates accurate Task 4894 diagnostics report', () {
      final bridge = Vol115Wave8UIBridge();
      final report = bridge.getTask4894Diagnostics();

      expect(report['task_id'], equals(4894));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
