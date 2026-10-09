enum LinguisticCapability {
  morphologicalStacking,   // الالتصاق والتركيب الصرفي
  syntacticBranching,      // التفرع وبناء الجملة
  pragmaticMitigation,     // التلطيف والتسلسل الهرمي
  anaphoraCohesion,        // الإحالة والتماسك النصي
  phonologicalStress,      // النبر والتزامن الإيقاعي
  evidentiality,           // الشاهدية ومصدر المعرفة
  collocationalTension,    // التلازم اللفظي والجذب الدلالي
  zeroEquivalence,         // الحذف والاختزال التداولي
  honorificDistance,       // المسافة الاجتماعية وصيغ الخطاب
  conversationalImplicature, // الاستلزام الحواري والتضمين
  hesitationRepair,        // حشوات التردد وإصلاح الحديث
  phonotacticHarmony,      // التناغم الصوتي وتتابع السواكن
  scalarImplicature,       // السلالم الدلالية والاستلزام التدرجي
  prosodicFocus,           // النبر البؤري والتنغيم النغمي
  taxonomicGranularity,    // التخصيص المعجمي والتجريد
  counterfactualMood,      // الشك والافتراض المضاد للواقع
}

class LanguagePair {
  final String sourceIso;
  final String targetIso;

  const LanguagePair({
    required this.sourceIso,
    required this.targetIso,
  });

  String get key => '${sourceIso}_$targetIso';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguagePair &&
          runtimeType == other.runtimeType &&
          sourceIso == other.sourceIso &&
          targetIso == other.targetIso;

  @override
  int get hashCode => sourceIso.hashCode ^ targetIso.hashCode;
}
