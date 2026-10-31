enum TransitPhase {
  destinationInquiry,
  ticketClassAndReturn,
  platformAndConnection,
  paymentAndFareConfirmation,
  completed,
}

class TransitCorrectionHint {
  final String originalText;
  final String suggestedBetterPhrase;
  final String explanation;

  const TransitCorrectionHint({
    required this.originalText,
    required this.suggestedBetterPhrase,
    required this.explanation,
  });
}

class TransitTurnResult {
  final TransitPhase nextPhase;
  final String agentResponse;
  final bool goalAchieved;
  final TransitCorrectionHint? correctionHint;

  const TransitTurnResult({
    required this.nextPhase,
    required this.agentResponse,
    required this.goalAchieved,
    this.correctionHint,
  });
}

class TravelTransitRoleplayScenario {
  final String targetLanguage;
  final String cefrLevel;
  TransitPhase currentPhase;

  TravelTransitRoleplayScenario({
    this.targetLanguage = 'de',
    this.cefrLevel = 'A2',
    this.currentPhase = TransitPhase.destinationInquiry,
  });

  /// Evaluates learner input at the DB travel counter.
  TransitTurnResult evaluateUserTurn(String userText) {
    final lower = userText.trim().toLowerCase();
    TransitCorrectionHint? hint;

    // Detect improper preposition with destination (e.g. "nach Berlin" vs "zu Berlin")
    if (lower.contains('zu berlin') || lower.contains('in berlin fahren')) {
      hint = const TransitCorrectionHint(
        originalText: 'zu Berlin',
        suggestedBetterPhrase: 'nach Berlin',
        explanation: 'For cities and countries without an article in German, use the preposition "nach".',
      );
    }

    switch (currentPhase) {
      case TransitPhase.destinationInquiry:
        if (lower.contains('berlin') || lower.contains('münchen') || lower.contains('hamburg') || lower.contains('fahrkarte') || lower.contains('ticket')) {
          currentPhase = TransitPhase.ticketClassAndReturn;
          return TransitTurnResult(
            nextPhase: currentPhase,
            agentResponse: 'Guten Tag! Sehr gerne. Möchten Sie einfach fahren oder hin und zurück? Und erste oder zweite Klasse?',
            goalAchieved: true,
            correctionHint: hint,
          );
        }
        return TransitTurnResult(
          nextPhase: currentPhase,
          agentResponse: 'Guten Tag! Wohin möchten Sie reisen?',
          goalAchieved: false,
          correctionHint: hint,
        );

      case TransitPhase.ticketClassAndReturn:
        if (lower.contains('einfach') || lower.contains('hin und zurück') || lower.contains('zweite') || lower.contains('erste') || lower.contains('klasse')) {
          currentPhase = TransitPhase.platformAndConnection;
          return TransitTurnResult(
            nextPhase: currentPhase,
            agentResponse: 'Alles klar. Der nächste ICE fährt um 10:24 Uhr von Gleis 7 ab. Sie müssen in Hannover einmal umsteigen.',
            goalAchieved: true,
            correctionHint: hint,
          );
        }
        return TransitTurnResult(
          nextPhase: currentPhase,
          agentResponse: 'Brauchen Sie eine Rückfahrkarte und welche Wagenklasse bevorzugen Sie?',
          goalAchieved: false,
          correctionHint: hint,
        );

      case TransitPhase.platformAndConnection:
        if (lower.contains('gleis') || lower.contains('umsteigen') || lower.contains('verspätung') || lower.contains('danke') || lower.contains('reservierung')) {
          currentPhase = TransitPhase.paymentAndFareConfirmation;
          return TransitTurnResult(
            nextPhase: currentPhase,
            agentResponse: 'Der Zug ist pünktlich. Die Fahrkarte kostet 49 Euro. Zahlen Sie mit Karte oder bar?',
            goalAchieved: true,
            correctionHint: hint,
          );
        }
        return TransitTurnResult(
          nextPhase: currentPhase,
          agentResponse: 'Haben Sie noch Fragen zum Umsteigen oder zu Ihrem Sitzplatz?',
          goalAchieved: false,
          correctionHint: hint,
        );

      case TransitPhase.paymentAndFareConfirmation:
        if (lower.contains('karte') || lower.contains('bar') || lower.contains('zahlen') || lower.contains('bitte')) {
          currentPhase = TransitPhase.completed;
          return TransitTurnResult(
            nextPhase: currentPhase,
            agentResponse: 'Hier ist Ihr Ticket und der Beleg. Gute Reise und eine angenehme Fahrt!',
            goalAchieved: true,
            correctionHint: hint,
          );
        }
        return TransitTurnResult(
          nextPhase: currentPhase,
          agentResponse: 'Möchten Sie mit Karte oder bar bezahlen?',
          goalAchieved: false,
          correctionHint: hint,
        );

      case TransitPhase.completed:
        return const TransitTurnResult(
          nextPhase: TransitPhase.completed,
          agentResponse: 'Das Reiseszenario ist erfolgreich abgeschlossen. Gute Reise!',
          goalAchieved: true,
        );
    }
  }
}
