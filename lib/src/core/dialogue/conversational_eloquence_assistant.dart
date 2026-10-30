enum EloquenceCategory {
  registerElevation,
  idiomaticCollocation,
  connectiveVariety,
  lexicalNuance,
}

class EloquenceSuggestion {
  final EloquenceCategory category;
  final String originalPhrase;
  final String suggestedAlternative;
  final String targetCefrLevel;
  final String nuanceExplanation;

  const EloquenceSuggestion({
    required this.category,
    required this.originalPhrase,
    required this.suggestedAlternative,
    required this.targetCefrLevel,
    required this.nuanceExplanation,
  });

  Map<String, dynamic> toJson() => {
    'category': category.name,
    'originalPhrase': originalPhrase,
    'suggestedAlternative': suggestedAlternative,
    'targetCefrLevel': targetCefrLevel,
    'nuanceExplanation': nuanceExplanation,
  };
}

class ConversationalEloquenceAssistant {
  const ConversationalEloquenceAssistant();

  /// Suggests more natural, eloquent, or higher-register alternatives for a learner's utterance.
  List<EloquenceSuggestion> suggestEloquenceAlternatives(String utterance) {
    final suggestions = <EloquenceSuggestion>[];
    final lower = utterance.trim().toLowerCase();

    // 1. Collocation: "Sport machen" -> "Sport treiben"
    if (lower.contains('sport mache') || lower.contains('sport gemacht') || lower.contains('mache sport')) {
      suggestions.add(const EloquenceSuggestion(
        category: EloquenceCategory.idiomaticCollocation,
        originalPhrase: 'Sport machen',
        suggestedAlternative: 'Sport treiben',
        targetCefrLevel: 'B1',
        nuanceExplanation: '"Sport treiben" is the authentic, idiomatic German expression used by native speakers.',
      ));
    }

    // 2. Register Elevation: "Ich will" -> "Ich würde gerne / Ich hätte gerne"
    if (lower.contains('ich will')) {
      suggestions.add(const EloquenceSuggestion(
        category: EloquenceCategory.registerElevation,
        originalPhrase: 'Ich will',
        suggestedAlternative: 'Ich würde gerne / Ich hätte gerne',
        targetCefrLevel: 'B1',
        nuanceExplanation: 'Using the subjunctive Konjunktiv II softens the demand into a refined, polite request.',
      ));
    }

    // 3. Connective Variety: Repetitive "und dann" -> "Anschließend / Daraufhin"
    if (lower.contains('und dann')) {
      suggestions.add(const EloquenceSuggestion(
        category: EloquenceCategory.connectiveVariety,
        originalPhrase: 'und dann',
        suggestedAlternative: 'anschließend / daraufhin / danach',
        targetCefrLevel: 'B2',
        nuanceExplanation: 'Transition words like "anschließend" enrich sentence flow and demonstrate advanced sentence structure.',
      ));
    }

    // 4. Lexical Nuance: Overused "sehr gut" -> "ausgezeichnet / hervorragend"
    if (lower.contains('sehr gut')) {
      suggestions.add(const EloquenceSuggestion(
        category: EloquenceCategory.lexicalNuance,
        originalPhrase: 'sehr gut',
        suggestedAlternative: 'ausgezeichnet / hervorragend',
        targetCefrLevel: 'B2',
        nuanceExplanation: 'Substituting basic intensifiers with descriptive adjectives conveys precision and sophistication.',
      ));
    }

    return suggestions;
  }
}
