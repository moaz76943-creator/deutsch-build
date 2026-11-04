// Sovereign Polyglot Core - Task 2490 (Software Architecture)
class Task2490Engine {
  static const int taskId = 2490;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'festordnen';
  static const String praeteritum = 'ordnete fest';
  static const String perfekt = 'hat festgeordnet';
  static const String arabicTranslation = 'تثبيت / إقرار التصنيف (هندسة البرمجيات)';
  static const String ipaTranscription = '[festˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2490_festordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review festordnen.';
  static const String exampleArabic = 'يجب علينا تثبيت / إقرار التصنيف في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
