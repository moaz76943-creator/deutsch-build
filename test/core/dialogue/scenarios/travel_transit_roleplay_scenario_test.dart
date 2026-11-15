import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/dialogue/scenarios/travel_transit_roleplay_scenario.dart';

void main() {
  group('TravelTransitRoleplayScenario Tests', () {
    test('Simulates complete passenger workflow from inquiry to ticket receipt', () {
      final scenario = TravelTransitRoleplayScenario();
      expect(scenario.currentPhase, equals(TransitPhase.destinationInquiry));

      final turn1 = scenario.evaluateUserTurn('Ich möchte bitte eine Fahrkarte nach Berlin.');
      expect(turn1.goalAchieved, isTrue);
      expect(turn1.nextPhase, equals(TransitPhase.ticketClassAndReturn));

      final turn2 = scenario.evaluateUserTurn('Einfach und zweite Klasse bitte.');
      expect(turn2.goalAchieved, isTrue);
      expect(turn2.nextPhase, equals(TransitPhase.platformAndConnection));

      final turn3 = scenario.evaluateUserTurn('Von welchem Gleis fährt der Zug? Gibt es Verspätung?');
      expect(turn3.goalAchieved, isTrue);
      expect(turn3.nextPhase, equals(TransitPhase.paymentAndFareConfirmation));

      final turn4 = scenario.evaluateUserTurn('Ich bezahle mit Karte bitte.');
      expect(turn4.goalAchieved, isTrue);
      expect(turn4.nextPhase, equals(TransitPhase.completed));
    });

    test('Provides grammar hint when incorrect city preposition is detected', () {
      final scenario = TravelTransitRoleplayScenario();
      final result = scenario.evaluateUserTurn('Ich will zu Berlin fahren.');

      expect(result.correctionHint, isNotNull);
      expect(result.correctionHint!.originalText, equals('zu Berlin'));
      expect(result.correctionHint!.suggestedBetterPhrase, equals('nach Berlin'));
    });
  });
}
