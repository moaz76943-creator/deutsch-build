// Sovereign Polyglot Core - Task 2347
class Task2347Engine {
  static const int taskId = 2347;
  static const String verbInfinitive = 'weiterleiten';
  static const String praeteritum = 'leitete weiter';
  static const String perfekt = 'hat weitergeleitet';
  static const String arabicTranslation = 'يحول / يمرر';
  static const String ipaTranscription = '[ˈvaɪ̯tɐˌlaɪ̯tn̩]';
  static const String valencyCase = 'an + Akk';
  static const String cefrLevel = 'B1';
  static const String exampleGerman = 'Ich leite die E-Mail weiter.';
  static const String exampleArabic = 'سأقوم بتحويل البريد.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'verb': verbInfinitive, 'praeteritum': praeteritum,
    'perfekt': perfekt, 'arabic': arabicTranslation, 'ipa': ipaTranscription,
    'case': valencyCase, 'cefr': cefrLevel, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && praeteritum.isNotEmpty && perfekt.isNotEmpty;
}
