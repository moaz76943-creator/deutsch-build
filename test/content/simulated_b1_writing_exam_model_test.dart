import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/simulated_b1_writing_exam_model.dart';

void main() {
  group('SimulatedB1WritingExamModel Unit Tests (L050)', () {
    final model = SimulatedB1WritingExamModel();

    test('Contains standard B1 opinion essay prompt regarding plastic reduction', () {
      expect(SimulatedB1WritingExamModel.b1OpinionPrompt, contains('Plastikfreies Leben'));
      expect(SimulatedB1WritingExamModel.b1OpinionPrompt, contains('Heimatland'));
    });

    test('Validates compliant B1 essay covering opinion, reasons, alternatives, and connectors', () {
      const essay =
          'Meiner Meinung nach ist Umweltschutz eine sehr wichtige Aufgabe für uns alle. '
          'Wir sollten Plastikmüll konsequent vermeiden, weil Plastik die Ozeane und die Natur verschmutzt. '
          'Deshalb nutze ich beim Einkaufen immer wiederverwendbare Stoffbeutel und kaufe Milch in Glasflaschen. '
          'In meinem Heimatland wird auch immer mehr Wert auf Nachhaltigkeit gelegt. '
          'Außerdem sollten wir bewusster konsumieren.';

      final report = model.evaluateB1OpinionPost(essay);
      expect(report['isPassed'], isTrue);
      expect(report['fulfilledPointsCount'], equals(4));
      expect(report['isLengthSufficient'], isTrue);
      expect(report['hasConnectors'], isTrue);
    });
  });
}
