/// Type of medial construction in German grammar.
enum MedialConstructionType {
  facilitiveMedial,      // Das Buch liest sich leicht (سهولة الفعل)
  automaticInanimate,    // Die Tür öffnet sich von selbst (تلقائية الحدث)
  impersonalEvaluative,  // Hier lebt es sich gut (تقييم تجربة المكان)
}

/// Analysis descriptor of an engineered medial voice sentence and its passive paraphrase.
class MedialVoiceTransformation {
  final String surfaceSubject;
  final String verbInfinitive;
  final String mandatoryQualifyingAdverb;
  final MedialConstructionType type;
  final String medialSentence;
  final String passiveModalParaphrase;
  final String arabicEquivalence;

  MedialVoiceTransformation({
    required this.surfaceSubject,
    required this.verbInfinitive,
    required this.mandatoryQualifyingAdverb,
    required this.type,
    required this.medialSentence,
    required this.passiveModalParaphrase,
    required this.arabicEquivalence,
  });

  Map<String, dynamic> toJson() => {
        'subject': surfaceSubject,
        'verb': verbInfinitive,
        'adverb': mandatoryQualifyingAdverb,
        'type': type.name,
        'medial': medialSentence,
        'passive_equiv': passiveModalParaphrase,
        'arabic': arabicEquivalence,
      };
}

/// Offline rule engine analyzing German Medial Voice Constructions (Medialkonstruktionen).
/// Converts sentences with middle-voice semantics (Subject + Verb + sich + Adverb)
/// into their exact modal passive equivalents (kann + Partizip II + werden / man kann + Infinitiv).
class GermanMedialVoiceEngine {
  /// Construct medial voice sentence and compute its passive paraphrase.
  static MedialVoiceTransformation constructMedial({
    required String subject,
    required String verbInfinitive,
    required String conjugatedVerb3rd, // e.g. "liest", "wäscht", "bedient", "schließt"
    required String partizipTwo,        // e.g. "gelesen", "gewaschen", "bedient", "geschlossen"
    required String qualifyingAdverb,   // e.g. "leicht", "gut", "schwer", "angenehm", "von selbst"
    MedialConstructionType type = MedialConstructionType.facilitiveMedial,
  }) {
    final cleanSubj = subject.trim();
    final cleanVerb = verbInfinitive.trim().toLowerCase();
    final cleanAdv = qualifyingAdverb.trim().toLowerCase();

    String medial = '';
    String passive = '';
    String arabic = '';

    if (type == MedialConstructionType.impersonalEvaluative) {
      // Impersonal: Hier lebt es sich gut -> Hier kann man gut leben
      medial = '$cleanSubj $conjugatedVerb3rd es sich $cleanAdv.';
      passive = '$cleanSubj kann man $cleanAdv $cleanVerb.';
      arabic = 'صيغة متوسطة مجردة (Impersonal Medial): تفيد قابلية وجودة المعيشة أو الفعل في ذلك المكان';
    } else if (type == MedialConstructionType.automaticInanimate) {
      // Inanimate automatic: Die Tür schließt sich von selbst
      medial = '$cleanSubj $conjugatedVerb3rd sich $cleanAdv.';
      passive = '$cleanSubj wird automatisch / ohne äußeren Eingriff $partizipTwo.';
      arabic = 'صيغة متوسطة دالة على التلقائية دون فاعل بشري ظاهر';
    } else {
      // Facilitive: Das Buch liest sich leicht -> Das Buch kann leicht gelesen werden
      medial = '$cleanSubj $conjugatedVerb3rd sich $cleanAdv.';
      passive = '$cleanSubj kann $cleanAdv $partizipTwo werden.';
      arabic = 'صيغة متوسطة (Medialkonstruktion): فاعل غير عاقل مع ضمير انعكاسي وظرف كيفية يفيد قابلية الفعل وسهولته بصيغة المبني للمجهول';
    }

    return MedialVoiceTransformation(
      surfaceSubject: cleanSubj,
      verbInfinitive: cleanVerb,
      mandatoryQualifyingAdverb: cleanAdv,
      type: type,
      medialSentence: medial,
      passiveModalParaphrase: passive,
      arabicEquivalence: arabic,
    );
  }
}
