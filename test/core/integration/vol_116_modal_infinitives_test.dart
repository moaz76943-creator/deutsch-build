import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/content/german_modal_infinitives_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave24_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4924 Modal Infinitives Engine Tests', () {
    test('LING-047: haben zu conveys strict active necessity (müssen)', () {
      final res = GermanModalInfinitivesEngine.constructPhrase(
        subject: 'Du',
        conjugatedAuxiliary: 'hast',
        type: ModalInfinitiveType.habenZuObligation,
        actionVerb: 'befolgen',
        complement: 'diese Anweisung',
      );

      expect(res.type, equals(ModalInfinitiveType.habenZuObligation));
      expect(res.generatedSentence, equals('Du hast diese Anweisung zu befolgen.'));
      expect(res.modalVerbEquivalent, equals('Du muss diese Anweisung befolgen.'));
      expect(res.arabicExplanation, contains('إلزام ووجوب'));
    });

    test('LING-047: nicht brauchen zu conveys absence of obligation', () {
      final res = GermanModalInfinitivesEngine.constructPhrase(
        subject: 'Du',
        conjugatedAuxiliary: 'brauchst nicht',
        type: ModalInfinitiveType.brauchenNichtZu,
        actionVerb: 'warten',
        complement: 'auf mich',
      );

      expect(res.type, equals(ModalInfinitiveType.brauchenNichtZu));
      expect(res.generatedSentence, equals('Du brauchst nicht auf mich zu warten.'));
      expect(res.modalVerbEquivalent, equals('Du muss nicht auf mich warten.'));
    });

    test('LING-047: scheinen zu conveys evidentiality', () {
      final res = GermanModalInfinitivesEngine.constructPhrase(
        subject: 'Die Lage',
        conjugatedAuxiliary: 'scheint',
        type: ModalInfinitiveType.scheinenZuEvidential,
        actionVerb: 'beruhigen',
        complement: 'sich',
      );

      expect(res.type, equals(ModalInfinitiveType.scheinenZuEvidential));
      expect(res.generatedSentence, equals('Die Lage scheint sich zu beruhigen.'));
    });

    test('UI Bridge generates accurate Task 4924 diagnostics report', () {
      final bridge = Vol116Wave24UIBridge();
      final report = bridge.getTask4924Diagnostics();

      expect(report['task_id'], equals(4924));
      expect(report['volume'], equals(116));
      expect(report['tasks_remaining_to_5000'], equals(76));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
