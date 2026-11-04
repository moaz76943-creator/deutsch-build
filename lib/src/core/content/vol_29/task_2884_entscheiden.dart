// Sovereign Polyglot Core - Task 2884
class Task2884Engine {
  static const int taskId = 2884;
  static const String verbInfinitive = 'entscheiden';
  static const String praeteritum = 'entschied';
  static const String perfekt = 'hat entschieden';
  static const String arabicTranslation = 'يقرر / يحسم';
  static const String ipaTranscription = '[ʔɛntˈʃaɪ̯dn̩]';
  static const String valencyCase = 'über + Akk';
  static const String cefrLevel = 'B1';
  static const String exampleGerman = 'Die Jury hat entschieden.';
  static const String exampleArabic = 'حسمت لجنة التحكيم القرار.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'verb': verbInfinitive, 'praeteritum': praeteritum,
    'perfekt': perfekt, 'arabic': arabicTranslation, 'ipa': ipaTranscription,
    'case': valencyCase, 'cefr': cefrLevel, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && praeteritum.isNotEmpty && perfekt.isNotEmpty;
}
