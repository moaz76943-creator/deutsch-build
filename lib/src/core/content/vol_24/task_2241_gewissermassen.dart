// Sovereign Adverbial Modifier Core - Task 2241
class Task2241Engine {
  static const int taskId = 2241;
  static const String identifier = 'gewissermassen';
  static const String adverbGerman = 'gewissermaßen';
  static const String arabicMeaning = 'إلى حد ما / بنوع من التعبير';
  static const String ipaTranscription = '[ɡəˈvɪsɐˌmaːsn̩]';
  static const String cefrLevel = 'C1';
  static const String grammaticalCategory = 'Satzadverb';
  static const String audioAssetPath = 'assets/audio/adv/task_2241_gewissermassen.ogg';
  static const String exampleGerman = 'Das ist gewissermaßen der Kern des Problems.';
  static const String exampleArabic = 'هذا إلى حد ما جوهر المشكلة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'adverb': adverbGerman,
    'arabic': arabicMeaning, 'ipa': ipaTranscription, 'cefr': cefrLevel,
    'category': grammaticalCategory, 'audio': audioAssetPath,
    'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => adverbGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
