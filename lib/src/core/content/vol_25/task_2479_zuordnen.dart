// Sovereign Polyglot Core - Task 2479 (Software Architecture)
class Task2479Engine {
  static const int taskId = 2479;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'zuordnen';
  static const String praeteritum = 'ordnete zu';
  static const String perfekt = 'hat zugeordnet';
  static const String arabicTranslation = 'توجيه / إغلاق التصنيف (هندسة البرمجيات)';
  static const String ipaTranscription = '[zuˈˈɔʁdnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2479_zuordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review zuordnen.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق التصنيف في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
