// Sovereign Polyglot Core - Task 2482 (Software Architecture)
class Task2482Engine {
  static const int taskId = 2482;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'verordnen';
  static const String praeteritum = 'verordnete';
  static const String perfekt = 'hat verordnet';
  static const String arabicTranslation = 'توثيق / معالجة التصنيف (هندسة البرمجيات)';
  static const String ipaTranscription = '[verˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2482_verordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review verordnen.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة التصنيف في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
