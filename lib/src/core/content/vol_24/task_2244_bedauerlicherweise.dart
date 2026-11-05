// Sovereign Adverbial Modifier Core - Task 2244
class Task2244Engine {
  static const int taskId = 2244;
  static const String identifier = 'bedauerlicherweise';
  static const String adverbGerman = 'bedauerlicherweise';
  static const String arabicMeaning = 'للأسف الشديد / مع بالغ الأسف';
  static const String ipaTranscription = '[bəˈdaʊ̯ɐlɪçɐˌvaɪ̯zə]';
  static const String cefrLevel = 'B2';
  static const String grammaticalCategory = 'Satzadverb';
  static const String audioAssetPath = 'assets/audio/adv/task_2244_bedauerlicherweise.ogg';
  static const String exampleGerman = 'Bedauerlicherweise gab es Verzoegerungen.';
  static const String exampleArabic = 'للأسف الشديد حدثت بعض التأخيرات.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'adverb': adverbGerman,
    'arabic': arabicMeaning, 'ipa': ipaTranscription, 'cefr': cefrLevel,
    'category': grammaticalCategory, 'audio': audioAssetPath,
    'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => adverbGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
