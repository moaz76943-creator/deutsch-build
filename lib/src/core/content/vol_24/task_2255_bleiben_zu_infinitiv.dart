// Sovereign Passive Alternate Core - Task 2255
class Task2255Engine {
  static const int taskId = 2255;
  static const String identifier = 'bleiben_zu_infinitiv';
  static const String alternateForm = 'bleiben + zu + Infinitiv';
  static const String arabicFunction = 'يتبقى أن يُفعل / ما زال يتطلب إنجازاً';
  static const String cefrLevel = 'C1';
  static const String syntacticFunction = 'Verbleibende Pflicht';
  static const String audioAssetPath = 'assets/audio/passive/task_2255_bleiben_zu_infinitiv.ogg';
  static const String exampleGerman = 'Es bleibt abzuwarten, wie es endet.';
  static const String exampleArabic = 'يتبقى أن ننتظر لنرى كيف ستنتهي الأمور.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'form': alternateForm,
    'arabic': arabicFunction, 'cefr': cefrLevel, 'function': syntacticFunction,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => alternateForm.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
