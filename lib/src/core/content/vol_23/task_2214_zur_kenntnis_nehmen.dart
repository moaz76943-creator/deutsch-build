// Sovereign Functional Verb Core - Task 2214
class Task2214Engine {
  static const int taskId = 2214;
  static const String identifier = 'zur_kenntnis_nehmen';
  static const String phraseGerman = 'zur Kenntnis nehmen';
  static const String arabicMeaning = 'يحيط علماً بـ / يسجل ملاحظة';
  static const String ipaTranscription = '[tsuːɐ̯ ˈkɛntnɪs ˈneːmən]';
  static const String cefrLevel = 'B2';
  static const String simpleVerbEquivalent = 'bemerken / wahrnehmen';
  static const String audioAssetPath = 'assets/audio/fvg/task_2214_zur_kenntnis_nehmen.ogg';
  static const String exampleGerman = 'Ich habe den Bericht zur Kenntnis genommen.';
  static const String exampleArabic = 'أحطت علماً بفحوى التقرير الرسمي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': phraseGerman,
    'arabic': arabicMeaning, 'ipa': ipaTranscription, 'cefr': cefrLevel,
    'equivalent': simpleVerbEquivalent, 'audio': audioAssetPath,
    'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => phraseGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
