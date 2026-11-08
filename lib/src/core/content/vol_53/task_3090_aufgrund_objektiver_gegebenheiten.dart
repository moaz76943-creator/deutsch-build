// Sovereign Legal & Normative Precision Core - Task 3090
class Task3090Engine {
  static const int taskId = 3090;
  static const String identifier = 'aufgrund_objektiver_gegebenheiten';
  static const String normativePhrase = 'aufgrund objektiver Gegebenheiten';
  static const String arabicMeaning = 'بناءً على معطيات وحقائق عتادية ثابتة وملموسة';
  static const String cefrLevel = 'B1';
  static const String legalCategory = 'Faktische Kausalität';
  static const String audioAssetPath = 'assets/audio/normative/task_3090_aufgrund_objektiver_gegebenheiten.ogg';
  static const String exampleGerman = 'Aufgrund objektiver Gegebenheiten wählen wir 32KB-Pages.';
  static const String exampleArabic = 'بناءً على معطيات موضوعية، نعتمد صفحات ذاكرة بسعة 32KB.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': normativePhrase,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': legalCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => normativePhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
