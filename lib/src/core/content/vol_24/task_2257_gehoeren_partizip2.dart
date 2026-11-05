// Sovereign Passive Alternate Core - Task 2257
class Task2257Engine {
  static const int taskId = 2257;
  static const String identifier = 'gehoeren_partizip2';
  static const String alternateForm = 'gehören + Partizip II';
  static const String arabicFunction = 'يستحق / ينبغي بالضرورة أن يُفعل';
  static const String cefrLevel = 'B2';
  static const String syntacticFunction = 'Dringende Empfehlung';
  static const String audioAssetPath = 'assets/audio/passive/task_2257_gehoeren_partizip2.ogg';
  static const String exampleGerman = 'Der Code gehoert gruendlich geprueft.';
  static const String exampleArabic = 'ينبغي فحص الشيفرة البرمجية بدقة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'form': alternateForm,
    'arabic': arabicFunction, 'cefr': cefrLevel, 'function': syntacticFunction,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => alternateForm.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
