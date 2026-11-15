import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/dialogue/scenarios/restaurant_roleplay_scenario.dart';

void main() {
  group('RestaurantRoleplayScenario Tests', () {
    test('Scenario guides learner from greeting to paying bill', () {
      final scenario = RestaurantRoleplayScenario();

      expect(scenario.currentPhase, equals(RestaurantPhase.greetingAndSeating));

      final turn1 = scenario.evaluateUserTurn('Guten Tag, einen Tisch bitte.');
      expect(turn1.goalAchieved, isTrue);
      expect(turn1.nextPhase, equals(RestaurantPhase.requestingMenu));

      final turn2 = scenario.evaluateUserTurn('Ich möchte ein Mineralwasser und eine Suppe bitte.');
      expect(turn2.goalAchieved, isTrue);
      expect(turn2.nextPhase, equals(RestaurantPhase.requestingBill));

      final turn3 = scenario.evaluateUserTurn('Die Rechnung bitte, ich möchte zahlen.');
      expect(turn3.goalAchieved, isTrue);
      expect(turn3.nextPhase, equals(RestaurantPhase.completed));
    });

    test('Corrects impolite phrasing politely without breaking conversational flow', () {
      final scenario = RestaurantRoleplayScenario(currentPhase: RestaurantPhase.orderingFoodAndDrink);

      final result = scenario.evaluateUserTurn('Ich will ein Bier.');
      expect(result.correctionHint, isNotNull);
      expect(result.correctionHint!.originalText, equals('Ich will'));
      expect(result.correctionHint!.suggestedBetterPhrase, contains('Ich möchte bitte'));
    });
  });
}
