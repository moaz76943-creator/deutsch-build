// Sovereign Rigorous Discourse Core - Task 2906
class Task2906Engine {
  static const int taskId = 2906;
  static const String identifier = 'stimmt_im_wesentlichen_ueberein';
  static const String phraseGerman = 'stimmt im Wesentlichen überein';
  static const String arabicMeaning = 'يتطابق جوهرياً وفي كافة الأركان الأساسية';
  static const String cefrLevel = 'B2';
  static const String evaluativeCategory = 'Substanzielle Übereinstimmung';
  static const String audioAssetPath = 'assets/audio/discourse/task_2906_stimmt_im_wesentlichen_ueberein.ogg';
  static const String exampleGerman = 'Das Schema stimmt im Wesentlichen mit dem Standard überein.';
  static const String exampleArabic = 'يتطابق المخطط جوهرياً وفي كافة أركانه مع المعيار المعتمد.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': phraseGerman,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': evaluativeCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => phraseGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
