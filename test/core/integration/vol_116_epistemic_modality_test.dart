import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/content/german_epistemic_modality_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave6_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4906 Epistemic Modality Engine Tests', () {
    test('LING-029: müssen represents logical conclusion with high certainty', () {
      final res = GermanEpistemicModalityEngine.analyzeEpistemicUsage(
        subject: 'Er',
        modalVerb: 'muss',
        predicateAction: 'krank sein',
      );

      expect(res.degree, equals(EpistemicDegree.almostCertain));
      expect(res.probabilityPercentage, equals(95));
      expect(res.modalSentence, equals('Er muss krank sein.'));
      expect(res.arabicExplanation, contains('شبه مؤكد'));
    });

    test('LING-029: sollen represents reported 3rd-party rumor', () {
      final res = GermanEpistemicModalityEngine.analyzeEpistemicUsage(
        subject: 'Der Nachbar',
        modalVerb: 'soll',
        predicateAction: 'reich sein',
      );

      expect(res.degree, equals(EpistemicDegree.reportedRumor));
      expect(res.modalSentence, equals('Der Nachbar soll reich sein.'));
      expect(res.objectiveParaphrase, contains('Die Leute sagen'));
    });

    test('LING-029: Past epistemic construction forms Partizip II + Infinitiv Perfekt', () {
      final res = GermanEpistemicModalityEngine.analyzeEpistemicUsage(
        subject: 'Sie',
        modalVerb: 'dürfte',
        predicateAction: '',
        isPastTime: true,
        pastParticiple: 'angekommen',
        usesSeinAuxiliary: true,
      );

      expect(res.degree, equals(EpistemicDegree.highlyProbable));
      expect(res.modalSentence, equals('Sie dürfte angekommen sein.'));
    });

    test('UI Bridge generates accurate Task 4906 diagnostics report', () {
      final bridge = Vol116Wave6UIBridge();
      final report = bridge.getTask4906Diagnostics();

      expect(report['task_id'], equals(4906));
      expect(report['volume'], equals(116));
      expect(report['tasks_remaining_to_5000'], equals(94));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
