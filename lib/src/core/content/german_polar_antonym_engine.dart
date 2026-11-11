/// Domain of the polar semantic relationship.
enum AntonymDomain { trendsQuantity, opinionEvaluation, legalFormal, physicalState }

/// Descriptor of an aligned antonymic pair.
class PolarAntonymPair {
  final String positiveTerm;
  final String negativeTerm;
  final AntonymDomain domain;
  final String typicalSubjectOrContext;
  final String commonUsageErrorNotice;
  final String arabicEquivalence;

  const PolarAntonymPair({
    required this.positiveTerm,
    required this.negativeTerm,
    required this.domain,
    required this.typicalSubjectOrContext,
    required this.commonUsageErrorNotice,
    required this.arabicEquivalence,
  });

  Map<String, dynamic> toJson() => {
        'pos': positiveTerm,
        'neg': negativeTerm,
        'domain': domain.name,
        'context': typicalSubjectOrContext,
        'error_notice': commonUsageErrorNotice,
        'arabic': arabicEquivalence,
      };
}

/// Offline rule engine validating German polar antonyms and catching improper collocation pairings
/// (z.B. steigen vs. sinken für Preise/Zahlen, zunehmen vs. abnehmen für Intensität/Gewicht).
class GermanPolarAntonymEngine {
  static const List<PolarAntonymPair> _pairDirectory = [
    PolarAntonymPair(
      positiveTerm: 'steigen',
      negativeTerm: 'sinken',
      domain: AntonymDomain.trendsQuantity,
      typicalSubjectOrContext: 'Preise, Kosten, Temperaturen, Zahlen (intransitiv)',
      commonUsageErrorNotice: 'لا يجوز استخدام zunehmen للأسعار (*die Preise nehmen zu خطأ شائع، والصواب: steigen)',
      arabicEquivalence: 'يرتفع / ينخفض (للأسعار والمقادير العددية)',
    ),
    PolarAntonymPair(
      positiveTerm: 'erhoehen',
      negativeTerm: 'senken',
      domain: AntonymDomain.trendsQuantity,
      typicalSubjectOrContext: 'jemand erhöht/senkt die Preise (transitiv mit Akkusativ)',
      commonUsageErrorNotice: 'فعل متعدٍّ يتطلب فاعلاً ومفعولاً به، بخلاف steigen/sinken اللازمين',
      arabicEquivalence: 'يرفع / يخفّض (فعل متعدٍّ بالفاعل)',
    ),
    PolarAntonymPair(
      positiveTerm: 'zunehmen',
      negativeTerm: 'abnehmen',
      domain: AntonymDomain.trendsQuantity,
      typicalSubjectOrContext: 'Gewicht, Druck, Intensität, Interesse',
      commonUsageErrorNotice: 'يستخدم لتنامي الصفة والوزن والشدة المعنوية',
      arabicEquivalence: 'يزداد / ينقص (للوزن والكثافة والشدة)',
    ),
    PolarAntonymPair(
      positiveTerm: 'befuerworten',
      negativeTerm: 'ablehnen',
      domain: AntonymDomain.opinionEvaluation,
      typicalSubjectOrContext: 'Vorschläge, Anträge, Gesetze',
      commonUsageErrorNotice: 'فعل راقٍ في السجل الأكاديمي والسياسي يعبر عن الدعم الصريح',
      arabicEquivalence: 'يؤيد ويحبذ / يرفض ويعارض',
    ),
    PolarAntonymPair(
      positiveTerm: 'bejahen',
      negativeTerm: 'verneinen',
      domain: AntonymDomain.legalFormal,
      typicalSubjectOrContext: 'Fragen, Grundsätze, Verantwortung',
      commonUsageErrorNotice: 'يعني الإجابة بنعم (bejahen) أو بلا (verneinen) في السياق القانوني والفكري',
      arabicEquivalence: 'يجيب بالإيجاب / يجيب بالنفي والإنكار',
    ),
  ];

  /// Find antonym for a given positive or negative term.
  static PolarAntonymPair? findPair(String term) {
    final clean = term.trim().toLowerCase()
        .replaceAll('ä', 'ae')
        .replaceAll('ö', 'oe')
        .replaceAll('ü', 'ue');

    for (final pair in _pairDirectory) {
      if (pair.positiveTerm == clean || pair.negativeTerm == clean) {
        return pair;
      }
    }
    return null;
  }

  /// Critical check for improper collocation (e.g. *die Preise nehmen zu).
  static String? auditSubjectVerbPairing(String subject, String verb) {
    final s = subject.trim().toLowerCase();
    final v = verb.trim().toLowerCase();

    if (s.contains('preis') && (v.contains('zunehmen') || v.contains('nimmt zu'))) {
      return 'تنبيه تدقيق نقدي: الأسعار ترتفع (steigen) ولا "تزداد" (zunehmen). الصحيح: Die Preise steigen.';
    }
    if (s.contains('gewicht') && (v.contains('steigen') || v.contains('steigt'))) {
      return 'تنبيه تدقيق نقدي: الوزن يزداد (zunehmen) ولا يقال له steigen. الصحيح: Das Gewicht nimmt zu.';
    }

    return null; // Clean
  }
}
