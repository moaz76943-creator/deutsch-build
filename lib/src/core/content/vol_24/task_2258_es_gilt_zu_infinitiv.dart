// Sovereign Passive Alternate Core - Task 2258
class Task2258Engine {
  static const int taskId = 2258;
  static const String identifier = 'es_gilt_zu_infinitiv';
  static const String alternateForm = 'es gilt + zu + Infinitiv';
  static const String arabicFunction = 'يتعين ويتحتم القيام بـ';
  static const String cefrLevel = 'C1';
  static const String syntacticFunction = 'Zwingende Notwendigkeit';
  static const String audioAssetPath = 'assets/audio/passive/task_2258_es_gilt_zu_infinitiv.ogg';
  static const String exampleGerman = 'Es gilt, alle Fehlerquellen zu meiden.';
  static const String exampleArabic = 'يتعين تجنب كافة مصادر الأخطاء.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'form': alternateForm,
    'arabic': arabicFunction, 'cefr': cefrLevel, 'function': syntacticFunction,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => alternateForm.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
