// Sovereign Passive Alternate Core - Task 2251
class Task2251Engine {
  static const int taskId = 2251;
  static const String identifier = 'sein_zu_infinitiv';
  static const String alternateForm = 'sein + zu + Infinitiv';
  static const String arabicFunction = 'يجب / يمكن أن يُفعل (صيغة الجرونديف)';
  static const String cefrLevel = 'C1';
  static const String syntacticFunction = 'Notwendigkeit / Moeglichkeit';
  static const String audioAssetPath = 'assets/audio/passive/task_2251_sein_zu_infinitiv.ogg';
  static const String exampleGerman = 'Die Daten sind sofort zu sichern.';
  static const String exampleArabic = 'يجب حفظ وتأمين البيانات فوراً.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'form': alternateForm,
    'arabic': arabicFunction, 'cefr': cefrLevel, 'function': syntacticFunction,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => alternateForm.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
