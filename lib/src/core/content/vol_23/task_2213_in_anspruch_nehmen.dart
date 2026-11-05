// Sovereign Functional Verb Core - Task 2213
class Task2213Engine {
  static const int taskId = 2213;
  static const String identifier = 'in_anspruch_nehmen';
  static const String phraseGerman = 'in Anspruch nehmen';
  static const String arabicMeaning = 'يستفيد من / يستهلك وقتاً وجهداً';
  static const String ipaTranscription = '[ɪn ˈʔanʃpʁʊx ˈneːmən]';
  static const String cefrLevel = 'C1';
  static const String simpleVerbEquivalent = 'nutzen / beanspruchen';
  static const String audioAssetPath = 'assets/audio/fvg/task_2213_in_anspruch_nehmen.ogg';
  static const String exampleGerman = 'Das Projekt nimmt viel Zeit in Anspruch.';
  static const String exampleArabic = 'المشروع يستهلك الكثير من الوقت والجهد.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': phraseGerman,
    'arabic': arabicMeaning, 'ipa': ipaTranscription, 'cefr': cefrLevel,
    'equivalent': simpleVerbEquivalent, 'audio': audioAssetPath,
    'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => phraseGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
