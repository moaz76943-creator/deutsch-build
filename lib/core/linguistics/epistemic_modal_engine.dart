enum EpistemicCertainty {
  nearCertainty,            // müssen: يقين قطعي واستنتاج حتمي (~95%)
  highProbability,          // dürfte: ترجيح راجح قوي (~75%)
  balancedPossibility,      // können: إمكانية محايدة متساوية (~50%)
  hypotheticalPossibility,  // könnte: احتمال ضعيف أو تخميني (~30%)
  hearsayReport,            // sollen: نقل عن مصادر أخرى وإشاعة (يقال إنه...)
  subjectiveClaim,          // wollen: ادعاء شخصي من الفاعل دون تصديق المتحدث (يدّعي أنه...)
}

class EpistemicProfile {
  final String verb;
  final EpistemicCertainty certainty;
  final int confidencePercent;
  final String arabicDefinition;

  const EpistemicProfile({
    required this.verb,
    required this.certainty,
    required this.confidencePercent,
    required this.arabicDefinition,
  });
}

/// Offline engine mapping German modal verbs to subjective probability scales and past inference forms.
class EpistemicModalEngine {
  static const Map<String, EpistemicProfile> _profiles = {
    'müssen': EpistemicProfile(
      verb: 'müssen',
      certainty: EpistemicCertainty.nearCertainty,
      confidencePercent: 95,
      arabicDefinition: 'استنتاج قطعي: لابد حتماً أنه كذا بناءً على أدلة دامغة',
    ),
    'dürfte': EpistemicProfile(
      verb: 'dürfte',
      certainty: EpistemicCertainty.highProbability,
      confidencePercent: 75,
      arabicDefinition: 'ترجيح قوي: من المرجح جداً والراجح',
    ),
    'können': EpistemicProfile(
      verb: 'können',
      certainty: EpistemicCertainty.balancedPossibility,
      confidencePercent: 50,
      arabicDefinition: 'إمكانية واردة: من الممكن، احتمال 50/50',
    ),
    'könnte': EpistemicProfile(
      verb: 'könnte',
      certainty: EpistemicCertainty.hypotheticalPossibility,
      confidencePercent: 30,
      arabicDefinition: 'احتمال افتراضي: قد يكون، مجرد تخمين',
    ),
    'sollen': EpistemicProfile(
      verb: 'sollen',
      certainty: EpistemicCertainty.hearsayReport,
      confidencePercent: 40,
      arabicDefinition: 'نقل وإشاعة: يُشاع ويُقال إنه كذا',
    ),
    'wollen': EpistemicProfile(
      verb: 'wollen',
      certainty: EpistemicCertainty.subjectiveClaim,
      confidencePercent: 20,
      arabicDefinition: 'ادعاء ذاتي: يزعم الفاعل بنفسه أنه كذا (والمتحدث يشكك)',
    ),
  };

  EpistemicProfile? getProfile(String modal) => _profiles[modal.toLowerCase()];

  /// صياغة التخمين الاستنتاجي للماضي (حتمية: فعل المودال بالحاضر + Partizip II + Infinitiv haben/sein)
  /// مثال: Er muss den Zug verpasst haben (استنتاج حالي عن حدث ماضٍ)
  String constructPastInference({
    required String subject,
    required String modalPresent,
    required String partizipIi,
    required String auxInfinitiv, // 'haben' or 'sein'
  }) {
    return '$subject $modalPresent $partizipIi $auxInfinitiv';
  }

  /// كشف ومنع الخطأ الشائع بصياغة المودال في الماضي التام عند التخمين
  /// فالصيغة "*Er musste den Zug verpassen" تعني إجباراً في الماضي وليس تخميناً
  bool isErroneousPastEpistemicForm(String modalUsed) {
    const pastForms = {'musste', 'durfte', 'konnte', 'sollte', 'wollte'};
    return pastForms.contains(modalUsed.toLowerCase());
  }
}
