enum RestaurantPhase {
  greetingAndSeating,
  requestingMenu,
  orderingFoodAndDrink,
  askingRecommendations,
  requestingBill,
  completed,
}

class LanguageCorrectionHint {
  final String originalText;
  final String suggestedBetterPhrase;
  final String explanation;

  const LanguageCorrectionHint({
    required this.originalText,
    required this.suggestedBetterPhrase,
    required this.explanation,
  });
}

class ScenarioTurnResult {
  final RestaurantPhase nextPhase;
  final String waiterResponse;
  final bool goalAchieved;
  final LanguageCorrectionHint? correctionHint;

  const ScenarioTurnResult({
    required this.nextPhase,
    required this.waiterResponse,
    required this.goalAchieved,
    this.correctionHint,
  });
}

class RestaurantRoleplayScenario {
  final String targetLanguage;
  final String cefrLevel;
  RestaurantPhase currentPhase;

  RestaurantRoleplayScenario({
    this.targetLanguage = 'de',
    this.cefrLevel = 'A2',
    this.currentPhase = RestaurantPhase.greetingAndSeating,
  });

  /// Evaluates user utterance and drives roleplay scenario to completion.
  ScenarioTurnResult evaluateUserTurn(String userText) {
    final lower = userText.trim().toLowerCase();
    LanguageCorrectionHint? hint;

    // Detect overly direct demand "Ich will..." and suggest polite subjunctive "Ich möchte bitte..."
    if (lower.contains('ich will')) {
      hint = const LanguageCorrectionHint(
        originalText: 'Ich will',
        suggestedBetterPhrase: 'Ich möchte bitte...',
        explanation: 'In restaurants, "Ich möchte bitte" is much more polite than "Ich will".',
      );
    }

    switch (currentPhase) {
      case RestaurantPhase.greetingAndSeating:
        if (lower.contains('hallo') || lower.contains('guten tag') || lower.contains('tisch')) {
          currentPhase = RestaurantPhase.requestingMenu;
          return ScenarioTurnResult(
            nextPhase: currentPhase,
            waiterResponse: 'Guten Tag! Willkommen im Restaurant Lindenhof. Hier ist Ihr Tisch und die Speisekarte.',
            goalAchieved: true,
            correctionHint: hint,
          );
        }
        return ScenarioTurnResult(
          nextPhase: currentPhase,
          waiterResponse: 'Guten Tag! Suchen Sie einen Tisch für eine oder zwei Personen?',
          goalAchieved: false,
          correctionHint: hint,
        );

      case RestaurantPhase.requestingMenu:
      case RestaurantPhase.orderingFoodAndDrink:
        if (lower.contains('wasser') || lower.contains('kaffee') || lower.contains('suppe') || lower.contains('salat') || lower.contains('möchte') || lower.contains('nehme')) {
          currentPhase = RestaurantPhase.requestingBill;
          return ScenarioTurnResult(
            nextPhase: currentPhase,
            waiterResponse: 'Hervorragende Wahl! Das bringe ich Ihnen sofort. Hat es Ihnen geschmeckt?',
            goalAchieved: true,
            correctionHint: hint,
          );
        }
        return ScenarioTurnResult(
          nextPhase: currentPhase,
          waiterResponse: 'Was darf ich Ihnen zu trinken oder zu essen bringen?',
          goalAchieved: false,
          correctionHint: hint,
        );

      case RestaurantPhase.askingRecommendations:
        return ScenarioTurnResult(
          nextPhase: currentPhase,
          waiterResponse: 'Ich empfehle Ihnen heute unsere frische Tagessuppe.',
          goalAchieved: true,
          correctionHint: hint,
        );

      case RestaurantPhase.requestingBill:
        if (lower.contains('rechnung') || lower.contains('zahlen') || lower.contains('bezahlen')) {
          currentPhase = RestaurantPhase.completed;
          return ScenarioTurnResult(
            nextPhase: currentPhase,
            waiterResponse: 'Zusammen oder getrennt? Das macht 14 Euro fünfzig, bitte. Auf Wiedersehen!',
            goalAchieved: true,
            correctionHint: hint,
          );
        }
        return ScenarioTurnResult(
          nextPhase: currentPhase,
          waiterResponse: 'Möchten Sie noch ein Dessert, oder darf ich die Rechnung bringen?',
          goalAchieved: false,
          correctionHint: hint,
        );

      case RestaurantPhase.completed:
        return const ScenarioTurnResult(
          nextPhase: RestaurantPhase.completed,
          waiterResponse: 'Das Restaurant-Szenario ist erfolgreich abgeschlossen!',
          goalAchieved: true,
        );
    }
  }
}
