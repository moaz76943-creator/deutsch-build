import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/content/german_derivational_morphology_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave10_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4910 Derivational Morphology Engine Tests', () {
    test('LING-033: Noun suffixes determine feminine gender die accurately', () {
      final resUng = GermanDerivationalMorphologyEngine.analyzeWord('Entscheidung');
      expect(resUng.resultingCategory, equals(DerivedPartOfSpeech.noun));
      expect(resUng.affix, equals('-ung'));
      expect(resUng.genderIfNoun, equals('die'));

      final resKeit = GermanDerivationalMorphologyEngine.analyzeWord('Möglichkeit');
      expect(resKeit.genderIfNoun, equals('die'));
      expect(resKeit.affix, equals('-keit'));

      final resSchaft = GermanDerivationalMorphologyEngine.analyzeWord('Freundschaft');
      expect(resSchaft.genderIfNoun, equals('die'));
    });

    test('LING-033: Adjective suffixes identify semantic function accurately', () {
      final resBar = GermanDerivationalMorphologyEngine.analyzeWord('lösbar');
      expect(resBar.resultingCategory, equals(DerivedPartOfSpeech.adjective));
      expect(resBar.affix, equals('-bar'));
      expect(resBar.semanticFunction, contains('إمكانية'));

      final resLos = GermanDerivationalMorphologyEngine.analyzeWord('arbeitslos');
      expect(resLos.affix, equals('-los'));
      expect(resLos.semanticFunction, contains('نفي'));
    });

    test('LING-033: Inseparable verbal prefixes detect semantic modification', () {
      final resZer = GermanDerivationalMorphologyEngine.analyzeWord('zerbrechen');
      expect(resZer.resultingCategory, equals(DerivedPartOfSpeech.verb));
      expect(resZer.affix, equals('zer-'));
      expect(resZer.semanticFunction, contains('التحطيم'));

      final resBe = GermanDerivationalMorphologyEngine.analyzeWord('beantworten');
      expect(resBe.affix, equals('be-'));
      expect(resBe.semanticFunction, contains('متعد'));
    });

    test('UI Bridge generates accurate Task 4910 diagnostics report', () {
      final bridge = Vol116Wave10UIBridge();
      final report = bridge.getTask4910Diagnostics();

      expect(report['task_id'], equals(4910));
      expect(report['volume'], equals(116));
      expect(report['tasks_remaining_to_5000'], equals(90));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
