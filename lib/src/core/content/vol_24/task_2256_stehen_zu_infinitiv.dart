// Sovereign Passive Alternate Core - Task 2256
class Task2256Engine {
  static const int taskId = 2256;
  static const String identifier = 'stehen_zu_infinitiv';
  static const String alternateForm = 'stehen + zu + Infinitiv';
  static const String arabicFunction = 'يُتوقع أن / في حكم المؤكد أن يحدث';
  static const String cefrLevel = 'C1';
  static const String syntacticFunction = 'Erwartbarkeit';
  static const String audioAssetPath = 'assets/audio/passive/task_2256_stehen_zu_infinitiv.ogg';
  static const String exampleGerman = 'Es steht zu befeuerchten, dass...';
  static const String exampleArabic = 'يُخشى من أن تحدث انتكاسة في الخطة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'form': alternateForm,
    'arabic': arabicFunction, 'cefr': cefrLevel, 'function': syntacticFunction,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => alternateForm.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
