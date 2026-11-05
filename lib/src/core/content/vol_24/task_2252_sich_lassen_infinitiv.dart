// Sovereign Passive Alternate Core - Task 2252
class Task2252Engine {
  static const int taskId = 2252;
  static const String identifier = 'sich_lassen_infinitiv';
  static const String alternateForm = 'sich lassen + Infinitiv';
  static const String arabicFunction = 'يمكن أن يُفعل / قابل للتنفيذ';
  static const String cefrLevel = 'B2';
  static const String syntacticFunction = 'Moeglichkeit (Passiv-Ersatz)';
  static const String audioAssetPath = 'assets/audio/passive/task_2252_sich_lassen_infinitiv.ogg';
  static const String exampleGerman = 'Das Problem laesst sich leicht loesen.';
  static const String exampleArabic = 'يمكن حل هذه المشكلة بكل سهولة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'form': alternateForm,
    'arabic': arabicFunction, 'cefr': cefrLevel, 'function': syntacticFunction,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => alternateForm.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
