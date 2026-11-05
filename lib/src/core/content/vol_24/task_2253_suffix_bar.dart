// Sovereign Passive Alternate Core - Task 2253
class Task2253Engine {
  static const int taskId = 2253;
  static const String identifier = 'suffix_bar';
  static const String alternateForm = 'Adjektiv auf -bar';
  static const String arabicFunction = 'قابل لـ / يمكن إنجازه (مثل lösbar)';
  static const String cefrLevel = 'B1';
  static const String syntacticFunction = 'Passivische Faehigkeit';
  static const String audioAssetPath = 'assets/audio/passive/task_2253_suffix_bar.ogg';
  static const String exampleGerman = 'Die Aufgabe ist vollstaendig machbar.';
  static const String exampleArabic = 'المهمة قابلة للإنجاز بشكل كامل.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'form': alternateForm,
    'arabic': arabicFunction, 'cefr': cefrLevel, 'function': syntacticFunction,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => alternateForm.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
