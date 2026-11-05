// Sovereign Passive Alternate Core - Task 2254
class Task2254Engine {
  static const int taskId = 2254;
  static const String identifier = 'suffix_lich';
  static const String alternateForm = 'Adjektiv auf -lich';
  static const String arabicFunction = 'يتيح إمكانية (مثل erklärlich)';
  static const String cefrLevel = 'B2';
  static const String syntacticFunction = 'Potenzialitaet';
  static const String audioAssetPath = 'assets/audio/passive/task_2254_suffix_lich.ogg';
  static const String exampleGerman = 'Der Fehler ist leicht verstaendlich.';
  static const String exampleArabic = 'الخطأ يمكن فهمه واستيعابه بسهولة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'form': alternateForm,
    'arabic': arabicFunction, 'cefr': cefrLevel, 'function': syntacticFunction,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => alternateForm.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
