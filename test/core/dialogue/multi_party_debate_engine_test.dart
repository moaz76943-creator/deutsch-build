import 'package:test/test.dart';
import 'package:deutsch_build/src/core/dialogue/multi_party_debate_engine.dart';

void main() {
  group('MultiPartyDebateEngine Tests', () {
    test('Initiates debate with moderator, proponent, and opponent viewpoints', () {
      final engine = MultiPartyDebateEngine();
      final round = engine.initiateDebate();

      expect(round.nextStage, equals(DebateStage.learnerInput));
      expect(round.newStatements.length, equals(4));
      expect(round.newStatements.any((s) => s.speakerRole == DebateRole.proponent), isTrue);
      expect(round.newStatements.any((s) => s.speakerRole == DebateRole.opponent), isTrue);
      expect(round.newStatements.any((s) => s.speakerRole == DebateRole.moderator), isTrue);
    });

    test('Evaluates learner argument and provides advanced connector feedback', () {
      final engine = MultiPartyDebateEngine();
      engine.initiateDebate();

      final result = engine.submitLearnerArgument('Einerseits ist Homeoffice flexibel, andererseits fehlt der Kontakt.');

      expect(result.learnerTurnCompleted, isTrue);
      expect(result.nextStage, equals(DebateStage.conclusion));
      expect(result.argumentationFeedback, contains('Ausgezeichnete Argumentationsstruktur'));
    });
  });
}
