// Sovereign Participial Attribute Core - Task 2290
class Task2290Engine {
  static const int taskId = 2290;
  static const String identifier = 'praezise_formulierter_entwurf';
  static const String participialPhrase = 'der präzise formulierte Entwurf';
  static const String arabicMeaning = 'المسودة المصاغة بدقة متناهية';
  static const String syntacticType = 'Partizip II mit Qualitätsadverb';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/partizip/task_2290_praezise_formulierter_entwurf.ogg';
  static const String exampleGerman = 'Der präzise formulierte Entwurf fand Anklang.';
  static const String exampleArabic = 'المسودة المصاغة بدقة نالت الاستحسان.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': participialPhrase,
    'arabic': arabicMeaning, 'type': syntacticType, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => participialPhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
