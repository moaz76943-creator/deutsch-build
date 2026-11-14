import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/content/german_nominalization_converter.dart';
import 'package:deutsch_build/src/ui/bridges/vol_115_wave9_ui_bridge.dart';

void main() {
  group('Volume 115 Task 4895 Nominalization Converter Tests', () {
    test('LING-018: Nominal prepositional patterns map to correct subordinate conjunctions', () {
      final temporalPair = GermanNominalizationConverter.findVerbalEquivalent('Beim Essen');
      expect(temporalPair, isNotNull);
      expect(temporalPair!.verbalConjunction, contains('während'));
      expect(temporalPair.relationship, equals(ConnectorRelationship.temporal));

      final causalPair = GermanNominalizationConverter.findVerbalEquivalent('Wegen des Wetters');
      expect(causalPair, isNotNull);
      expect(causalPair!.verbalConjunction, contains('weil'));
      expect(causalPair.relationship, equals(ConnectorRelationship.causal));

      final concessivePair = GermanNominalizationConverter.findVerbalEquivalent('Trotz des Regens');
      expect(concessivePair, isNotNull);
      expect(concessivePair!.verbalConjunction, contains('obwohl'));
      expect(concessivePair.relationship, equals(ConnectorRelationship.concessive));
    });

    test('LING-018: Functional verb collocations simplify to basic verbs accurately', () {
      final match1 = GermanNominalizationConverter.resolveCollocation('Wir müssen eine Entscheidung treffen.');
      expect(match1, isNotNull);
      expect(match1!.simpleVerb, equals('sich entscheiden'));
      expect(match1.arabicMeaning, equals('يتخذ قراراً'));

      final match2 = GermanNominalizationConverter.resolveCollocation('Der Lehrer übte Kritik.');
      expect(match2, isNotNull);
      expect(match2!.simpleVerb, equals('kritisieren'));
    });

    test('UI Bridge generates accurate Task 4895 diagnostics report', () {
      final bridge = Vol115Wave9UIBridge();
      final report = bridge.getTask4895Diagnostics();

      expect(report['task_id'], equals(4895));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
      expect(bridge.simplifyCollocation('Hilfe leisten')?.simpleVerb, equals('helfen'));
    });
  });
}
