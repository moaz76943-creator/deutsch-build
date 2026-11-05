// Sovereign Adverbial Modifier Core - Task 2245
class Task2245Engine {
  static const int taskId = 2245;
  static const String identifier = 'bekanntlich';
  static const String adverbGerman = 'bekanntlich';
  static const String arabicMeaning = 'كما هو معلوم ومشهور للجميع';
  static const String ipaTranscription = '[bəˈkantlɪç]';
  static const String cefrLevel = 'B2';
  static const String grammaticalCategory = 'Faktizitaetsadverb';
  static const String audioAssetPath = 'assets/audio/adv/task_2245_bekanntlich.ogg';
  static const String exampleGerman = 'Bekanntlich benoetigt Software Tests.';
  static const String exampleArabic = 'كما هو معلوم، تحتاج البرمجيات للاختبار.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'adverb': adverbGerman,
    'arabic': arabicMeaning, 'ipa': ipaTranscription, 'cefr': cefrLevel,
    'category': grammaticalCategory, 'audio': audioAssetPath,
    'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => adverbGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
