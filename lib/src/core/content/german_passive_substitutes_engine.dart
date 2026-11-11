/// Type of passive substitute construction in German.
enum PassiveSubstituteType {
  seinPlusZu,       // sein + zu + Infinitiv (kann / muss gelöst werden)
  sichLassen,       // sich lassen + Infinitiv (kann gelöst werden)
  adjectiveSuffix,  // Adjektiv auf -bar / -lich (lösbar, machbar)
}

/// Modal meaning underlying the passive substitute.
enum UnderlyingModalMeaning { possibilityKann, obligationMuss }

/// Transformation analysis descriptor comparing passive substitute with true modal passive.
class PassiveSubstituteAnalysis {
  final String subject;
  final String verbInfinitive;
  final PassiveSubstituteType substituteType;
  final UnderlyingModalMeaning modalMeaning;
  final String substituteSentence;
  final String modalPassiveEquivalent;
  final String arabicExplanation;

  PassiveSubstituteAnalysis({
    required this.subject,
    required this.verbInfinitive,
    required this.substituteType,
    required this.modalMeaning,
    required this.substituteSentence,
    required this.modalPassiveEquivalent,
    required this.arabicExplanation,
  });

  Map<String, dynamic> toJson() => {
        'subject': subject,
        'verb': verbInfinitive,
        'type': substituteType.name,
        'modal': modalMeaning.name,
        'substitute': substituteSentence,
        'passive_equiv': modalPassiveEquivalent,
        'arabic': arabicExplanation,
      };
}

/// Offline rule engine transforming and validating German Passive Voice Substitutes (Passiversatzformen).
/// Converts active colloquial & academic structures into their true passive equivalents (können/müssen + Passiv).
class GermanPassiveSubstitutesEngine {
  /// Transform concept into a passive substitute and provide modal passive equivalent.
  static PassiveSubstituteAnalysis construct({
    required String subject,
    required String verbInfinitive,
    required String partizipTwo,
    PassiveSubstituteType type = PassiveSubstituteType.seinPlusZu,
    UnderlyingModalMeaning modal = UnderlyingModalMeaning.possibilityKann,
    String adjectiveRoot = '',
  }) {
    final cleanSubject = subject.trim();
    final cleanVerb = verbInfinitive.trim().toLowerCase();

    String subSentence = '';
    String modalEquivalent = '';
    String arabic = '';

    final modalVerb = (modal == UnderlyingModalMeaning.obligationMuss) ? 'muss' : 'kann';
    modalEquivalent = '$cleanSubject $modalVerb $partizipTwo werden.';

    switch (type) {
      case PassiveSubstituteType.seinPlusZu:
        // sein + zu + Infinitiv: z.B. "Das Problem ist zu lösen."
        subSentence = '$cleanSubject ist zu $cleanVerb.';
        arabic = (modal == UnderlyingModalMeaning.obligationMuss)
            ? 'صيغة بديلة للمبني للمجهول تفيد الوجوب (يجب أن يتم...)'
            : 'صيغة بديلة للمبني للمجهول تفيد الإمكانية (يمكن أن يتم...)';
        break;

      case PassiveSubstituteType.sichLassen:
        // sich lassen + Infinitiv: z.B. "Das Problem lässt sich lösen."
        subSentence = '$cleanSubject lässt sich $cleanVerb.';
        arabic = 'صيغة بديلة للمبني للمجهول باستخدام sich lassen تفيد الإمكانية (يمكن إنجازه)';
        break;

      case PassiveSubstituteType.adjectiveSuffix:
        // Adjektiv auf -bar / -lich: z.B. "Das Problem ist lösbar."
        final adj = adjectiveRoot.isNotEmpty ? adjectiveRoot : '${cleanVerb.replaceAll(RegExp(r'en$'), '')}bar';
        subSentence = '$cleanSubject ist $adj.';
        arabic = 'صيغة بديلة مشتقة كصفة تفيد قابلية الفعل (قابل لـ...)';
        break;
    }

    return PassiveSubstituteAnalysis(
      subject: cleanSubject,
      verbInfinitive: cleanVerb,
      substituteType: type,
      modalMeaning: modal,
      substituteSentence: subSentence,
      modalPassiveEquivalent: modalEquivalent,
      arabicExplanation: arabic,
    );
  }
}
