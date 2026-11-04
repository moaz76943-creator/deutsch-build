// Sovereign Polyglot Core - Task 3451
class Task3451Engine {
  static const int taskId = 3451;
  static const String verbInfinitive = 'unterbrechen';
  static const String praeteritum = 'unterbrach';
  static const String perfekt = 'hat unterbrochen';
  static const String arabicTranslation = 'يقاطع / يعلق';
  static const String ipaTranscription = '[ʔʊntɐˈbʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String exampleGerman = 'Darf ich Sie kurz unterbrechen?';
  static const String exampleArabic = 'هل تسمح لي بمقاطعتك؟';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'verb': verbInfinitive, 'praeteritum': praeteritum,
    'perfekt': perfekt, 'arabic': arabicTranslation, 'ipa': ipaTranscription,
    'case': valencyCase, 'cefr': cefrLevel, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && praeteritum.isNotEmpty && perfekt.isNotEmpty;
}
