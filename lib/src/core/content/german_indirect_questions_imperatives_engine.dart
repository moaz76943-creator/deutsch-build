/// Type of reported communicative speech act.
enum ReportedSpeechActType {
  yesNoQuestionOb,    // Entscheidungsfrage (ob ...)
  whQuestion,         // Ergänzungsfrage (wer, wie, wo, wann ...)
  imperativeCommand,  // Aufforderung / Befehl (solle / sollten + Infinitiv)
}

/// Analysis descriptor of a constructed indirect question or command.
class IndirectSpeechActStructure {
  final String reportingIntro;
  final ReportedSpeechActType actType;
  final String introductoryConnector; // "ob", W-Word, or connector
  final String reportedSubject;
  final String reportedActionCluster;
  final String fullIndirectSentence;
  final String arabicExplanation;

  IndirectSpeechActStructure({
    required this.reportingIntro,
    required this.actType,
    required this.introductoryConnector,
    required this.reportedSubject,
    required this.reportedActionCluster,
    required this.fullIndirectSentence,
    required this.arabicExplanation,
  });

  Map<String, dynamic> toJson() => {
        'intro': reportingIntro,
        'act_type': actType.name,
        'connector': introductoryConnector,
        'subject': reportedSubject,
        'action_cluster': reportedActionCluster,
        'sentence': fullIndirectSentence,
        'arabic': arabicExplanation,
      };
}

/// Offline rule engine transforming direct questions and commands into indirect reported speech
/// (Indirekte Rede: Fragen mit ob/W-Wort und Aufforderungen mit sollen).
class GermanIndirectQuestionsImperativesEngine {
  /// Transform direct question into reported indirect question.
  static IndirectSpeechActStructure transformQuestion({
    required String introMatrix, // e.g. "Der Kunde fragte" / "Sie wollte wissen"
    required String directQuestion,
    bool isYesNo = false,
    String? whWord, // e.g. "wann", "wo", "wie"
    required String subject,
    required String verbInKonjunktiv, // e.g. "ankomme", "beginne", "sei"
    String remainder = '',
  }) {
    final cleanIntro = introMatrix.trim().replaceAll(RegExp(r'[,.!?]$'), '');
    final cleanSubj = subject.trim();
    final cleanVerb = verbInKonjunktiv.trim();
    final cleanRem = remainder.trim();

    final connector = isYesNo ? 'ob' : (whWord != null ? whWord.trim().toLowerCase() : 'wie');
    final remStr = cleanRem.isNotEmpty ? ' $cleanRem' : '';

    final subClause = '$connector $cleanSubj$remStr $cleanVerb';
    final fullSentence = '$cleanIntro, $subClause.';

    final arabic = isYesNo
        ? 'سؤال غير مباشر مغلق (نعم/لا) مرتبط بأداة الربط (ob)'
        : 'سؤال غير مباشر مفتوح مرتبط بأداة الاستفهام (W-Wort) مع تأخير الفعل للنهاية';

    return IndirectSpeechActStructure(
      reportingIntro: cleanIntro,
      actType: isYesNo ? ReportedSpeechActType.yesNoQuestionOb : ReportedSpeechActType.whQuestion,
      introductoryConnector: connector,
      reportedSubject: cleanSubj,
      reportedActionCluster: '$remStr $cleanVerb'.trim(),
      fullIndirectSentence: fullSentence,
      arabicExplanation: arabic,
    );
  }

  /// Transform direct command/request into reported indirect imperative using "sollen".
  static IndirectSpeechActStructure transformImperative({
    required String introMatrix, // e.g. "Der Lehrer forderte" / "Die Mutter bat"
    required String reportedSubject,
    required String actionInfinitive, // e.g. "warten", "kommen", "die Aufgabe lösen"
    bool isPlural = false,
  }) {
    final cleanIntro = introMatrix.trim().replaceAll(RegExp(r'[,.!?]$'), '');
    final cleanSubj = reportedSubject.trim();
    final modalAuxiliary = isPlural ? 'sollten' : 'solle';

    // Inversion/Subordinate: Subject + ... + Infinitive + solle/sollten
    final subClause = '$cleanSubj $actionInfinitive $modalAuxiliary'.replaceAll(RegExp(r'\s+'), ' ');
    final fullSentence = '$cleanIntro, $subClause.';

    return IndirectSpeechActStructure(
      reportingIntro: cleanIntro,
      actType: ReportedSpeechActType.imperativeCommand,
      introductoryConnector: '',
      reportedSubject: cleanSubj,
      reportedActionCluster: '$actionInfinitive $modalAuxiliary',
      fullIndirectSentence: fullSentence,
      arabicExplanation: 'طلب أو أمر غير مباشر مُحوّل باستخدام صيغة الفعل المساعد sollen في Konjunktiv I/II',
    );
  }
}
