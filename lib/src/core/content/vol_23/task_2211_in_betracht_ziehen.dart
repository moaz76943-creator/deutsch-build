// Sovereign Functional Verb Core - Task 2211
class Task2211Engine {
  static const int taskId = 2211;
  static const String identifier = 'in_betracht_ziehen';
  static const String phraseGerman = 'in Betracht ziehen';
  static const String arabicMeaning = 'يأخذ بعين الاعتبار / يدرس الاحتمال';
  static const String ipaTranscription = '[ɪn bəˈtʁaxt ˈtsiːən]';
  static const String cefrLevel = 'C1';
  static const String simpleVerbEquivalent = 'beruecksichtigen';
  static const String audioAssetPath = 'assets/audio/fvg/task_2211_in_betracht_ziehen.ogg';
  static const String exampleGerman = 'Wir muessen alle Optionen in Betracht ziehen.';
  static const String exampleArabic = 'يجب علينا أخذ جميع الخيارات بعين الاعتبار.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': phraseGerman,
    'arabic': arabicMeaning, 'ipa': ipaTranscription, 'cefr': cefrLevel,
    'equivalent': simpleVerbEquivalent, 'audio': audioAssetPath,
    'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => phraseGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
