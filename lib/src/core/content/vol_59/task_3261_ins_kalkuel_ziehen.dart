// Sovereign High-Register Idiom Core - Task 3261
class Task3261Engine {
  static const int taskId = 3261;
  static const String identifier = 'ins_kalkuel_ziehen';
  static const String idiomGerman = 'ins Kalkül ziehen';
  static const String arabicMeaning = 'يُدخل في الحسبان والتقدير الاستراتيجي الدقيق';
  static const String cefrLevel = 'C1';
  static const String pragmaticCategory = 'Strategische Reflexion';
  static const String audioAssetPath = 'assets/audio/idioms/task_3261_ins_kalkuel_ziehen.ogg';
  static const String exampleGerman = 'Wir ziehen Netzwerkschwankungen von Beginn an ins Kalkül.';
  static const String exampleArabic = 'نُدخل تذبذب الشبكة في الحسبان والتقدير من البداية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': idiomGerman,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': pragmaticCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => idiomGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
