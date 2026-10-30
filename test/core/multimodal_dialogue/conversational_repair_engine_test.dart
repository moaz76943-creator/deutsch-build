import 'package:test/test.dart';
import '../../lib/src/core/multimodal_dialogue/conversational_repair_engine.dart';

void main() {
  group('ConversationalRepairEngine Unit Tests (N064)', () {
    final engine = ConversationalRepairEngine();

    test('Deploys repetition request when acoustic clarity is degraded', () {
      final repair = engine.generateRepair(
        learnerUtterance: 'muffled sound',
        acousticClarityScore: 0.25,
        hasSyntaxError: false,
      );

      expect(repair.strategy, equals(RepairStrategy.repetitionRequest));
      expect(repair.repairPrompt, contains('Könntest du das bitte noch einmal sagen'));
    });

    test('Deploys gentle recast correction when syntax errors are detected', () {
      final repair = engine.generateRepair(
        learnerUtterance: 'Ich gehen heute Kino.',
        acousticClarityScore: 0.85,
        hasSyntaxError: true,
      );

      expect(repair.strategy, equals(RepairStrategy.recastCorrection));
      expect(repair.repairPrompt, contains('Ah, du möchtest sagen'));
    });

    test('Deploys confirmation check for one-word fragments', () {
      final repair = engine.generateRepair(
        learnerUtterance: 'Kino',
        acousticClarityScore: 0.90,
        hasSyntaxError: false,
      );

      expect(repair.strategy, equals(RepairStrategy.confirmationCheck));
    });
  });
}
