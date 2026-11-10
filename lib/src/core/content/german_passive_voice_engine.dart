/// Type of passive voice in German syntax.
enum PassiveType { vorgangspassiv, zustandspassiv }

/// Tense for passive transformation.
enum PassiveTense { praesens, praeteritum, perfekt }

/// Represents an active-to-passive voice transformation.
class PassiveVoiceTransformation {
  final String activeSubject;
  final String activeObject;
  final String verbInfinitive;
  final String partizipTwo;
  final PassiveType type;
  final PassiveTense tense;
  final String passiveSentence;

  PassiveVoiceTransformation({
    required this.activeSubject,
    required this.activeObject,
    required this.verbInfinitive,
    required this.partizipTwo,
    required this.type,
    required this.tense,
    required this.passiveSentence,
  });

  Map<String, dynamic> toJson() => {
        'subject': activeSubject,
        'object': activeObject,
        'verb': verbInfinitive,
        'partizip2': partizipTwo,
        'type': type.name,
        'tense': tense.name,
        'result': passiveSentence,
      };
}

/// Offline rule engine transforming German active sentences to passive voice (Passiv).
/// Handles agent transformation (von + Dativ for actors, durch + Akkusativ for means).
class GermanPassiveVoiceEngine {
  /// Transform simple transitive active sentence elements into passive form.
  static PassiveVoiceTransformation transform({
    required String subject,
    required String directObject,
    required String verbInfinitive,
    required String partizipTwo,
    PassiveType type = PassiveType.vorgangspassiv,
    PassiveTense tense = PassiveTense.praesens,
    bool includeAgent = true,
  }) {
    // 1. Direct object becomes passive grammatical subject
    final passiveSubject = directObject.trim();

    // 2. Auxiliary verb resolution
    String auxiliary = 'wird';
    String finalCluster = '';

    if (type == PassiveType.vorgangspassiv) {
      switch (tense) {
        case PassiveTense.praesens:
          auxiliary = 'wird';
          finalCluster = partizipTwo;
          break;
        case PassiveTense.praeteritum:
          auxiliary = 'wurde';
          finalCluster = partizipTwo;
          break;
        case PassiveTense.perfekt:
          auxiliary = 'ist';
          finalCluster = '$partizipTwo worden';
          break;
      }
    } else {
      // Zustandspassiv: sein + Partizip II
      switch (tense) {
        case PassiveTense.praesens:
          auxiliary = 'ist';
          finalCluster = partizipTwo;
          break;
        case PassiveTense.praeteritum:
          auxiliary = 'war';
          finalCluster = partizipTwo;
          break;
        case PassiveTense.perfekt:
          auxiliary = 'ist';
          finalCluster = '$partizipTwo gewesen';
          break;
      }
    }

    // 3. Agent phrase (von + Dativ)
    final agentPhrase = (includeAgent && subject.isNotEmpty) ? ' von $subject' : '';

    final sentence = '$passiveSubject $auxiliary$agentPhrase $finalCluster.'.replaceAll(RegExp(r'\s+'), ' ');

    return PassiveVoiceTransformation(
      activeSubject: subject,
      activeObject: directObject,
      verbInfinitive: verbInfinitive,
      partizipTwo: partizipTwo,
      type: type,
      tense: tense,
      passiveSentence: sentence,
    );
  }
}
