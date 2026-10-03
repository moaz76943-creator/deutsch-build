enum KonjunktivUsage {
  politeRequest,
  unrealWish,
  hypotheticalCondition,
  advice,
}

enum KonjunktivFormType {
  auxiliaryWuerde,
  coreOriginal,
}

final class KonjunktivChallengeItem {
  const KonjunktivChallengeItem({
    required this.id,
    required this.indicativeSentence,
    required this.konjunktivSentence,
    required this.targetVerb,
    required this.formType,
    required this.personalPronoun,
    required this.usage,
    required this.arabicTranslation,
    required this.arabicExplanation,
  })  : assert(id.length > 0),
        assert(indicativeSentence.length > 0),
        assert(konjunktivSentence.length > 0),
        assert(targetVerb.length > 0),
        assert(personalPronoun.length > 0),
        assert(arabicTranslation.length > 0),
        assert(arabicExplanation.length > 0);

  final String id;
  final String indicativeSentence;
  final String konjunktivSentence;
  final String targetVerb;
  final KonjunktivFormType formType;
  final String personalPronoun;
  final KonjunktivUsage usage;
  final String arabicTranslation;
  final String arabicExplanation;
}

extension KonjunktivUsageLabel on KonjunktivUsage {
  String get arabicLabel => switch (this) {
        KonjunktivUsage.politeRequest => 'طلب مؤدب',
        KonjunktivUsage.unrealWish => 'تمنٍ غير واقعي',
        KonjunktivUsage.hypotheticalCondition => 'شرط افتراضي',
        KonjunktivUsage.advice => 'نصيحة',
      };
}

extension KonjunktivFormTypeLabel on KonjunktivFormType {
  String get label => switch (this) {
        KonjunktivFormType.auxiliaryWuerde => 'würde + Infinitiv',
        KonjunktivFormType.coreOriginal => 'صيغة أصلية',
      };
}
