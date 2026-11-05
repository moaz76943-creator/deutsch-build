// Sovereign Passive Alternate Core - Task 2260
class Task2260Engine {
  static const int taskId = 2260;
  static const String identifier = 'finden_fvg_passiv';
  static const String alternateForm = 'Anwendung finden (Passiv-FVG)';
  static const String arabicFunction = 'يجد تطبيقاً / يُطبّق عملياً';
  static const String cefrLevel = 'C1';
  static const String syntacticFunction = 'Funktionsverbgefüge passivisch';
  static const String audioAssetPath = 'assets/audio/passive/task_2260_finden_fvg_passiv.ogg';
  static const String exampleGerman = 'Die neue Methodik findet breite Anwendung.';
  static const String exampleArabic = 'تجد المنهجية الجديدة تطبيقاً واسعاً.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'form': alternateForm,
    'arabic': arabicFunction, 'cefr': cefrLevel, 'function': syntacticFunction,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => alternateForm.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
