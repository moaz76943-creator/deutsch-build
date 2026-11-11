/// Epistemic degree or subjective function of the modal verb.
enum EpistemicDegree {
  almostCertain,      // müssen (95-100% - شبه مؤكد)
  highlyProbable,     // dürfte (75-80% - محتمل جداً)
  possible,           // kann / könnte (50% - ممكن)
  uncertainGuess,     // mag (30-40% - ربما / قد يكون)
  reportedRumor,      // sollen (يقال إن / شائعة منقولة)
  unverifiedClaim,    // wollen (يدعي / يزعم عن نفسه)
}

/// Analysis descriptor of subjective modal expression and its objective paraphrase.
class EpistemicModalAnalysis {
  final String modalVerb;
  final EpistemicDegree degree;
  final String subject;
  final String modalSentence;
  final String objectiveParaphrase;
  final int probabilityPercentage;
  final String arabicExplanation;

  EpistemicModalAnalysis({
    required this.modalVerb,
    required this.degree,
    required this.subject,
    required this.modalSentence,
    required this.objectiveParaphrase,
    required this.probabilityPercentage,
    required this.arabicExplanation,
  });

  Map<String, dynamic> toJson() => {
        'modal': modalVerb,
        'degree': degree.name,
        'subject': subject,
        'sentence': modalSentence,
        'paraphrase': objectiveParaphrase,
        'prob_percent': probabilityPercentage,
        'arabic': arabicExplanation,
      };
}

/// Offline rule engine resolving German Subjective/Epistemic Modal Verbs (Subjektive Modalverben).
/// Translates subjective assumptions and rumors into precise communicative paraphrases.
class GermanEpistemicModalityEngine {
  /// Construct and analyze an epistemic modal statement.
  static EpistemicModalAnalysis analyzeEpistemicUsage({
    required String subject,
    required String modalVerb,
    required String predicateAction, // e.g. "krank sein", "im Büro arbeiten", "die Wahrheit sagen"
    bool isPastTime = false,
    String pastParticiple = '',
    bool usesSeinAuxiliary = false,
  }) {
    final cleanModal = modalVerb.trim().toLowerCase();
    final cleanSubject = subject.trim();

    EpistemicDegree degree = EpistemicDegree.possible;
    int probability = 50;
    String paraphrase = '';
    String arabic = '';

    switch (cleanModal) {
      case 'muss':
      case 'müssen':
        degree = EpistemicDegree.almostCertain;
        probability = 95;
        paraphrase = 'Ich bin (fast) sicher, dass $cleanSubject ...';
        arabic = 'استنتاج منطقي شبه مؤكد (لا بد أنه...)';
        break;

      case 'dürfte':
      case 'duerfte':
        degree = EpistemicDegree.highlyProbable;
        probability = 80;
        paraphrase = 'Es ist sehr wahrscheinlich, dass $cleanSubject ...';
        arabic = 'احتمال راجح جداً (من المرجح بشدة...)';
        break;

      case 'kann':
      case 'könnte':
      case 'koennte':
        degree = EpistemicDegree.possible;
        probability = 50;
        paraphrase = 'Es ist möglich, dass $cleanSubject ...';
        arabic = 'إمكانية وفرضية قابلة للحدوث (من الممكن...)';
        break;

      case 'mag':
      case 'mögen':
        degree = EpistemicDegree.uncertainGuess;
        probability = 35;
        paraphrase = 'Vielleicht trifft es zu, dass $cleanSubject ...';
        arabic = 'تسليم وتخمين غير جازم (قد يكون...)';
        break;

      case 'soll':
      case 'sollen':
        degree = EpistemicDegree.reportedRumor;
        probability = 50;
        paraphrase = 'Die Leute sagen / Es wird berichtet, dass $cleanSubject ...';
        arabic = 'نقل خبر أو شائعة عن طرف ثالث (يقال إنه...)';
        break;

      case 'will':
      case 'wollen':
        degree = EpistemicDegree.unverifiedClaim;
        probability = 20;
        paraphrase = '$cleanSubject behauptet von sich selbst, dass ...';
        arabic = 'ادعاء شخصي غير مؤكد من الفاعل (يدعي / يزعم أنه...)';
        break;
    }

    // Sentence construction: Present vs Past Infinitiv Perfekt
    String sentence = '';
    if (isPastTime && pastParticiple.isNotEmpty) {
      final aux = usesSeinAuxiliary ? 'sein' : 'haben';
      sentence = '$cleanSubject $cleanModal $pastParticiple $aux.';
    } else {
      sentence = '$cleanSubject $cleanModal $predicateAction.';
    }

    return EpistemicModalAnalysis(
      modalVerb: cleanModal,
      degree: degree,
      subject: cleanSubject,
      modalSentence: sentence,
      objectiveParaphrase: paraphrase,
      probabilityPercentage: probability,
      arabicExplanation: arabic,
    );
  }
}
