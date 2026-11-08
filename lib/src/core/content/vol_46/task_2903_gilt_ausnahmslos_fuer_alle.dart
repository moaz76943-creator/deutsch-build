// Sovereign Rigorous Discourse Core - Task 2903
class Task2903Engine {
  static const int taskId = 2903;
  static const String identifier = 'gilt_ausnahmslos_fuer_alle';
  static const String phraseGerman = 'gilt ausnahmslos für alle Module';
  static const String arabicMeaning = 'يسري وينطبق حكماً دون أدنى استثناء على كافة العناصر';
  static const String cefrLevel = 'B2';
  static const String evaluativeCategory = 'Universelle Gültigkeit';
  static const String audioAssetPath = 'assets/audio/discourse/task_2903_gilt_ausnahmslos_fuer_alle.ogg';
  static const String exampleGerman = 'Die Typensicherheitsregel gilt ausnahmslos für alle Module.';
  static const String exampleArabic = 'تسري قاعدة الأمان النوعي الصارمة حكماً دون أدنى استثناء.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': phraseGerman,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': evaluativeCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => phraseGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
