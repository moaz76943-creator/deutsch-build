/// Grammatical mood applied in reported speech.
enum ReportedSpeechMood { konjunktiv1, fallbackKonjunktiv2 }

/// Reported speech transformation output descriptor.
class IndirectSpeechReport {
  final String directQuote;
  final String speaker;
  final String conjugatedVerb;
  final ReportedSpeechMood appliedMood;
  final String indirectSentence;

  IndirectSpeechReport({
    required this.directQuote,
    required this.speaker,
    required this.conjugatedVerb,
    required this.appliedMood,
    required this.indirectSentence,
  });

  Map<String, dynamic> toJson() => {
        'direct': directQuote,
        'speaker': speaker,
        'verb': conjugatedVerb,
        'mood': appliedMood.name,
        'indirect': indirectSentence,
      };
}

/// Offline rule engine converting direct speech quotes into indirect reported speech (Indirekte Rede).
/// Automatically applies Konjunktiv I, and falls back to Konjunktiv II when the form coincides with the indicative.
class GermanIndirectSpeechEngine {
  static const Map<String, String> _konjunktivOneRoots3rdPerson = {
    'sein': 'sei',
    'haben': 'habe',
    'werden': 'werde',
    'koennen': 'könne',
    'muessen': 'müsse',
    'wollen': 'wolle',
    'sollen': 'solle',
    'wissen': 'wisse',
    'kommen': 'komme',
    'gehen': 'gehe',
    'sagen': 'sage',
  };

  /// Convert direct utterance into indirect speech report.
  static IndirectSpeechReport reportUtterance({
    required String speaker,
    required String verbInfinitive,
    required String directQuote,
    bool isPluralSpeaker = false,
  }) {
    final cleanVerb = verbInfinitive.trim().toLowerCase()
        .replaceAll('ö', 'oe')
        .replaceAll('ä', 'ae')
        .replaceAll('ü', 'ue');

    String selectedVerbForm = '';
    ReportedSpeechMood mood = ReportedSpeechMood.konjunktiv1;

    if (!isPluralSpeaker) {
      // 3rd Person Singular (er/sie/es): Konjunktiv I is distinct
      selectedVerbForm = _konjunktivOneRoots3rdPerson[cleanVerb] ?? '${verbInfinitive.replaceAll(RegExp(r'n$'), '')}';
      mood = ReportedSpeechMood.konjunktiv1;
    } else {
      // 3rd Person Plural (sie): "sie haben" coincides with Indicative -> Fallback to Konjunktiv II "sie hätten"
      if (cleanVerb == 'haben') {
        selectedVerbForm = 'hätten';
        mood = ReportedSpeechMood.fallbackKonjunktiv2;
      } else if (cleanVerb == 'sein') {
        selectedVerbForm = 'seien';
        mood = ReportedSpeechMood.konjunktiv1; // "seien" is distinct
      } else {
        selectedVerbForm = 'würden ${verbInfinitive}';
        mood = ReportedSpeechMood.fallbackKonjunktiv2;
      }
    }

    final indirectSentence = '$speaker sagte, $directQuote $selectedVerbForm.'.replaceAll(RegExp(r'\s+'), ' ');

    return IndirectSpeechReport(
      directQuote: directQuote,
      speaker: speaker,
      conjugatedVerb: selectedVerbForm,
      appliedMood: mood,
      indirectSentence: indirectSentence,
    );
  }
}
