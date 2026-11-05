// Sovereign Functional Verb Core - Task 2217
class Task2217Engine {
  static const int taskId = 2217;
  static const String identifier = 'entscheidung_treffen';
  static const String phraseGerman = 'eine Entscheidung treffen';
  static const String arabicMeaning = 'يتخذ قراراً حاسماً';
  static const String ipaTranscription = '[ˈaɪ̯nə ʔɛntˈʃaɪ̯dʊŋ ˈtʁɛfn̩]';
  static const String cefrLevel = 'B1';
  static const String simpleVerbEquivalent = 'sich entscheiden';
  static const String audioAssetPath = 'assets/audio/fvg/task_2217_entscheidung_treffen.ogg';
  static const String exampleGerman = 'Der Vorstand hat die Entscheidung getroffen.';
  static const String exampleArabic = 'اتخذ مجلس الإدارة القرار النهائي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': phraseGerman,
    'arabic': arabicMeaning, 'ipa': ipaTranscription, 'cefr': cefrLevel,
    'equivalent': simpleVerbEquivalent, 'audio': audioAssetPath,
    'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => phraseGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
