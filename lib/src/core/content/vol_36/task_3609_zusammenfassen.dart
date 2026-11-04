// Sovereign Polyglot Core - Task 3609
class Task3609Engine {
  static const int taskId = 3609;
  static const String verbInfinitive = 'zusammenfassen';
  static const String praeteritum = 'fasste zusammen';
  static const String perfekt = 'hat zusammengefasst';
  static const String arabicTranslation = 'يلخص';
  static const String ipaTranscription = '[tsuˈzamn̩ˌfasn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B1';
  static const String exampleGerman = 'Fassen Sie den Text zusammen.';
  static const String exampleArabic = 'لخّص النص من فضلك.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'verb': verbInfinitive, 'praeteritum': praeteritum,
    'perfekt': perfekt, 'arabic': arabicTranslation, 'ipa': ipaTranscription,
    'case': valencyCase, 'cefr': cefrLevel, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && praeteritum.isNotEmpty && perfekt.isNotEmpty;
}
