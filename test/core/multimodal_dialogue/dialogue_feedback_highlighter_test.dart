import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/multimodal_dialogue/dialogue_feedback_highlighter.dart';

void main() {
  group('DialogueFeedbackHighlighter Unit Tests (N078)', () {
    final highlighter = DialogueFeedbackHighlighter();

    test('Compiles empathetic debrief and bounds flashcards to top 3 items', () {
      final slips = [
        const GrowthCard(originalLearnerUtterance: 'Ich gehen', nativeRecastCorrection: 'Ich gehe', linguisticDomain: 'grammar', explanatoryTip: 'Verbendung 1. Person'),
        const GrowthCard(originalLearnerUtterance: 'der Buch', nativeRecastCorrection: 'das Buch', linguisticDomain: 'vocabulary', explanatoryTip: 'Neutrum'),
        const GrowthCard(originalLearnerUtterance: 'für mir', nativeRecastCorrection: 'für mich', linguisticDomain: 'grammar', explanatoryTip: 'Akkusativ-Präposition'),
        const GrowthCard(originalLearnerUtterance: 'Katze schlaft', nativeRecastCorrection: 'Katze schläft', linguisticDomain: 'grammar', explanatoryTip: 'Umlaut'),
      ];

      final debrief = highlighter.compileDebrief(sessionTurns: 10, accuracyRatio: 0.85, loggedSlips: slips);

      expect(debrief.totalTurns, equals(10));
      expect(debrief.fluencyScore, equals(85.0));
      expect(debrief.celebratedStrengths.length, greaterThanOrEqualTo(2));
      expect(debrief.extractedFlashcards.length, equals(3)); // Capped at 3
      expect(debrief.extractedFlashcards.first.nativeRecastCorrection, equals('Ich gehe'));
    });

    test('Handles zero slips with celebratory debrief', () {
      final debrief = highlighter.compileDebrief(sessionTurns: 5, accuracyRatio: 1.0, loggedSlips: []);
      expect(debrief.extractedFlashcards, isEmpty);
      expect(debrief.fluencyScore, equals(100.0));
    });
  });
}
