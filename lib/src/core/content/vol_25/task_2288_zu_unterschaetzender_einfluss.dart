// Sovereign Participial Attribute Core - Task 2288
class Task2288Engine {
  static const int taskId = 2288;
  static const String identifier = 'zu_unterschaetzender_einfluss';
  static const String participialPhrase = 'der kaum zu unterschätzende Einfluss';
  static const String arabicMeaning = 'التأثير البالغ الذي لا يمكن الاستهانة به';
  static const String syntacticType = 'Gerundivum (Negation)';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/partizip/task_2288_zu_unterschaetzender_einfluss.ogg';
  static const String exampleGerman = 'Der kaum zu unterschätzende Einfluss ist spürbar.';
  static const String exampleArabic = 'الأثر الذي لا يمكن تجاهله ملموس بوضوح.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': participialPhrase,
    'arabic': arabicMeaning, 'type': syntacticType, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => participialPhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
