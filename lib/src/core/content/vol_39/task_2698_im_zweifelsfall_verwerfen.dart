// Sovereign System Evaluation Core - Task 2698
class Task2698Engine {
  static const int taskId = 2698;
  static const String identifier = 'im_zweifelsfall_verwerfen';
  static const String phraseGerman = 'im Zweifelsfall sofort verwerfen';
  static const String arabicMeaning = 'يستبعد ويرفض تلقائياً وفوراً عند أدنى شبهة أو شك';
  static const String cefrLevel = 'B1';
  static const String evaluativeCategory = 'Defensives Paradigma';
  static const String audioAssetPath = 'assets/audio/evaluative/task_2698_im_zweifelsfall_verwerfen.ogg';
  static const String exampleGerman = 'Beschädigte Pakete werden im Zweifelsfall sofort verworfen.';
  static const String exampleArabic = 'تُستبعد الحزم المعطوبة وترفض فوراً عند أدنى شبهة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': phraseGerman,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': evaluativeCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => phraseGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
