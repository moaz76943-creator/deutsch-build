import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/multimodal_dialogue/multimodal_dialogue_orchestrator.dart';

void main() {
  group('MultimodalDialogueOrchestrator Unit Tests (N061)', () {
    test('State machine transitions cleanly through listening, processing, speaking', () {
      final orchestrator = MultimodalDialogueOrchestrator();
      expect(orchestrator.currentPhase, equals(DialoguePhase.listening));

      orchestrator.attachVisualContext('Ein Apfel auf dem Tisch');
      expect(orchestrator.hasCameraContext, isTrue);

      final result = orchestrator.processUserTurn('Was ist das?');
      expect(result['status'], equals('success'));
      expect(result['visualGrounded'], isTrue);
      expect(orchestrator.turnCount, equals(2));
      expect(orchestrator.currentPhase, equals(DialoguePhase.speaking));
    });

    test('Immediate interruption transitions back to listening phase', () {
      final orchestrator = MultimodalDialogueOrchestrator();
      orchestrator.processUserTurn('Hallo!');
      expect(orchestrator.currentPhase, equals(DialoguePhase.speaking));

      orchestrator.handleInterruption();
      expect(orchestrator.currentPhase, equals(DialoguePhase.listening));
    });

    test('Empty utterance is ignored without phase transition', () {
      final orchestrator = MultimodalDialogueOrchestrator();
      final res = orchestrator.processUserTurn('');
      expect(res['status'], equals('ignored'));
      expect(orchestrator.currentPhase, equals(DialoguePhase.listening));
    });
  });
}
