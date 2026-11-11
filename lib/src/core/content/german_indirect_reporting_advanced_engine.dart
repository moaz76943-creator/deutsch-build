/// Reported tense category in indirect discourse.
enum IndirectDiscourseTense { present, past, future }

/// Transformation analysis descriptor of reported indirect speech with deictic shifts.
class AdvancedIndirectReport {
  final String speaker;
  final String originalDirectQuote;
  final IndirectDiscourseTense tense;
  final String shiftedPronoun;
  final String auxiliaryForm; // sei / habe / werde
  final String participleOrInfinitive;
  final String fullIndirectSentence;
  final Map<String, String> appliedDeicticShifts;

  AdvancedIndirectReport({
    required this.speaker,
    required this.originalDirectQuote,
    required this.tense,
    required this.shiftedPronoun,
    required this.auxiliaryForm,
    required this.participleOrInfinitive,
    required this.fullIndirectSentence,
    required this.appliedDeicticShifts,
  });

  Map<String, dynamic> toJson() => {
        'speaker': speaker,
        'direct': originalDirectQuote,
        'tense': tense.name,
        'shifted_pronoun': shiftedPronoun,
        'auxiliary': auxiliaryForm,
        'participle': participleOrInfinitive,
        'sentence': fullIndirectSentence,
        'deictic_shifts': appliedDeicticShifts,
      };
}

/// Offline rule engine constructing German indirect discourse in past and future tenses.
/// Automatically handles:
/// 1. Konjunktiv I Vergangenheit: sei/habe + Partizip II
/// 2. Konjunktiv I Zukunft: werde + Infinitiv
/// 3. Deictic shifts (heute -> an jenem Tag, gestern -> am Vortag, morgen -> am folgenden Tag, hier -> dort)
class GermanIndirectReportingAdvancedEngine {
  static const Map<String, String> _deicticShifts = {
    'heute': 'an jenem Tag',
    'gestern': 'am Vortag',
    'morgen': 'am folgenden Tag',
    'hier': 'dort',
    'jetzt': 'damals',
  };

  /// Build advanced indirect report with grammatical and deictic shifts.
  static AdvancedIndirectReport transformStatement({
    required String speaker,
    required String directQuote,
    required IndirectDiscourseTense tense,
    required String participleOrInfinitive,
    bool requiresSeinAuxiliary = false,
    bool isFemaleSpeaker = false,
    bool isPluralSpeaker = false,
  }) {
    // 1. Shift pronoun: ich -> er / sie / wir -> sie
    String shiftedPronoun = 'er';
    if (isPluralSpeaker) {
      shiftedPronoun = 'sie';
    } else if (isFemaleSpeaker) {
      shiftedPronoun = 'sie';
    }

    // 2. Select auxiliary:
    // Past: habe/sei + Partizip II
    // Future: werde + Infinitiv
    String aux = 'habe';
    if (tense == IndirectDiscourseTense.future) {
      aux = isPluralSpeaker ? 'würden' : 'werde';
    } else if (tense == IndirectDiscourseTense.past) {
      if (requiresSeinAuxiliary) {
        aux = isPluralSpeaker ? 'seien' : 'sei';
      } else {
        aux = isPluralSpeaker ? 'hätten' : 'habe'; // plural falls back to K2
      }
    } else {
      // Present
      if (requiresSeinAuxiliary) {
        aux = isPluralSpeaker ? 'seien' : 'sei';
      } else {
        aux = isPluralSpeaker ? 'hätten' : 'habe';
      }
    }

    // 3. Apply deictic shifts to the body text
    final shiftsApplied = <String, String>{};
    String processedBody = directQuote.trim();

    _deicticShifts.forEach((directWord, shiftedWord) {
      if (processedBody.contains(directWord)) {
        processedBody = processedBody.replaceAll(directWord, shiftedWord);
        shiftsApplied[directWord] = shiftedWord;
      }
    });

    // Remove terminal punctuation from quote
    processedBody = processedBody.replaceAll(RegExp(r'[,.!?]$'), '');

    final sentence = '$speaker erklärte, $shiftedPronoun $processedBody $participleOrInfinitive $aux.'
        .replaceAll(RegExp(r'\s+'), ' ');

    return AdvancedIndirectReport(
      speaker: speaker,
      originalDirectQuote: directQuote,
      tense: tense,
      shiftedPronoun: shiftedPronoun,
      auxiliaryForm: aux,
      participleOrInfinitive: participleOrInfinitive,
      fullIndirectSentence: sentence,
      appliedDeicticShifts: shiftsApplied,
    );
  }
}
