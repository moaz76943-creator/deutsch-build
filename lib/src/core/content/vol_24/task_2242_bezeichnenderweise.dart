// Sovereign Adverbial Modifier Core - Task 2242
class Task2242Engine {
  static const int taskId = 2242;
  static const String identifier = 'bezeichnenderweise';
  static const String adverbGerman = 'bezeichnenderweise';
  static const String arabicMeaning = 'من اللافت للنظر / كما هو متوقع دلالياً';
  static const String ipaTranscription = '[bəˈtsaɪ̯çnəndɐˌvaɪ̯zə]';
  static const String cefrLevel = 'C1';
  static const String grammaticalCategory = 'Kommentaradverb';
  static const String audioAssetPath = 'assets/audio/adv/task_2242_bezeichnenderweise.ogg';
  static const String exampleGerman = 'Er fehlte bezeichnenderweise beim Meeting.';
  static const String exampleArabic = 'تغيب عن الاجتماع بشكل ذي دلالة واضحة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'adverb': adverbGerman,
    'arabic': arabicMeaning, 'ipa': ipaTranscription, 'cefr': cefrLevel,
    'category': grammaticalCategory, 'audio': audioAssetPath,
    'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => adverbGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
