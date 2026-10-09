enum LinguisticCapability {
  morphologicalStacking,   // الالتصاق والتركيب الصرفي
  syntacticBranching,      // التفرع وبناء الجملة
  pragmaticMitigation,     // التلطيف والتسلسل الهرمي
  anaphoraCohesion,        // الإحالة والضمائر
  phonologicalStress,      // النبر والتزامن الإيقاعي
  evidentiality,           // اليقين ونقل المعرفة
}

class LanguagePair {
  final String sourceIso; // e.g., 'ar'
  final String targetIso; // e.g., 'de', 'es', 'tr'

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
