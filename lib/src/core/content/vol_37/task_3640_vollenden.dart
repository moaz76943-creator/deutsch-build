// Sovereign Polyglot Core - Task 3640
class Task3640Engine {
  static const int taskId = 3640;
  static const String verbInfinitive = 'vollenden';
  static const String praeteritum = 'vollendete';
  static const String perfekt = 'hat vollendet';
  static const String arabicTranslation = 'يتم / ينجز';
  static const String ipaTranscription = '[fɔlˈʔɛndn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String exampleGerman = 'Er vollendete sein Lebenswerk.';
  static const String exampleArabic = 'أنجز عمل حياته بالكامل.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'verb': verbInfinitive, 'praeteritum': praeteritum,
    'perfekt': perfekt, 'arabic': arabicTranslation, 'ipa': ipaTranscription,
    'case': valencyCase, 'cefr': cefrLevel, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && praeteritum.isNotEmpty && perfekt.isNotEmpty;
}
