enum HesitationTrigger {
  prolongedSilence,
  fillerOverload,
  danglingIncompleteClause,
}

class ScaffoldingHint {
  final HesitationTrigger trigger;
  final String sentenceStarter;
  final List<String> keywordSuggestions;
  final String encouragingNudge;

  const ScaffoldingHint({
    required this.trigger,
    required this.sentenceStarter,
    required this.keywordSuggestions,
    required this.encouragingNudge,
  });

  Map<String, dynamic> toJson() => {
    'trigger': trigger.name,
    'sentenceStarter': sentenceStarter,
    'keywordSuggestions': keywordSuggestions,
    'encouragingNudge': encouragingNudge,
  };
}

class HesitationScaffoldingEngine {
  static const int silenceThresholdMs = 2500; // 2.5 seconds

  const HesitationScaffoldingEngine();

  /// Analyzes utterance stream and silence duration to suggest contextual scaffolding.
  ScaffoldingHint? evaluateHesitation({
    required String partialTranscript,
    required int elapsedSilenceMs,
    required String currentScenarioContext,
  }) {
    final lower = partialTranscript.trim().toLowerCase();

    // 1. Check for filler sounds: "ähm", "uhm", "öhm"
    final int fillerCount = RegExp(r'\b(ähm|uhm|öhm|äh)\b').allMatches(lower).length;
    if (fillerCount >= 2) {
      return _generateScaffolding(HesitationTrigger.fillerOverload, currentScenarioContext);
    }

    // 2. Check for dangling incomplete subordinate clause: "weil...", "obwohl..."
    if (lower.endsWith('weil') || lower.endsWith('dass') || lower.endsWith('wenn') || lower.endsWith('obwohl')) {
      return _generateScaffolding(HesitationTrigger.danglingIncompleteClause, currentScenarioContext);
    }

    // 3. Prolonged silence beyond threshold
    if (elapsedSilenceMs >= silenceThresholdMs) {
      return _generateScaffolding(HesitationTrigger.prolongedSilence, currentScenarioContext);
    }

    return null;
  }

  ScaffoldingHint _generateScaffolding(HesitationTrigger trigger, String context) {
    if (context.toLowerCase().contains('restaurant')) {
      return ScaffoldingHint(
        trigger: trigger,
        sentenceStarter: 'Ich möchte gerne...',
        keywordSuggestions: const ['die Speisekarte', 'ein Mineralwasser', 'die Rechnung bitte'],
        encouragingNudge: 'Kein Stress! Versuchen Sie: "Ich möchte bitte..."',
      );
    } else if (context.toLowerCase().contains('bahnhof') || context.toLowerCase().contains('travel')) {
      return ScaffoldingHint(
        trigger: trigger,
        sentenceStarter: 'Eine Fahrkarte nach...',
        keywordSuggestions: const ['einfach', 'hin und zurück', 'Gleis'],
        encouragingNudge: 'Sagen Sie einfach Ihr Reiseziel: "Eine Fahrkarte nach Berlin, bitte."',
      );
    } else {
      return ScaffoldingHint(
        trigger: trigger,
        sentenceStarter: 'Ich denke, dass...',
        keywordSuggestions: const ['vielleicht', 'meiner Meinung nach', 'außerdem'],
        encouragingNudge: 'Lassen Sie sich Zeit. Beginnen Sie mit: "Ich denke, dass..."',
      );
    }
  }
}
