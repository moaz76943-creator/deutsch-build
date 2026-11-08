// Sovereign Rigorous Discourse Core - Task 3358
class Task3358Engine {
  static const int taskId = 3358;
  static const String identifier = 'im_zweifelsfall_sofort_verwerfen';
  static const String phraseGerman = 'im Zweifelsfall sofort verwerfen';
  static const String arabicMeaning = 'يستبعد ويرفض تلقائياً وفوراً عند أدنى شبهة أو شك';
  static const String cefrLevel = 'B1';
  static const String evaluativeCategory = 'Defensives Paradigma';
  static const String audioAssetPath = 'assets/audio/discourse/task_3358_im_zweifelsfall_sofort_verwerfen.ogg';
  static const String exampleGerman = 'Beschädigte Pakete werden im Zweifelsfall sofort verworfen.';
  static const String exampleArabic = 'تُستبعد الحزم المعطوبة وترفض فوراً عند أدنى شبهة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': phraseGerman,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': evaluativeCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => phraseGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
