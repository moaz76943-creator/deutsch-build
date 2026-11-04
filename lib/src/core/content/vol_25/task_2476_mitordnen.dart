// Sovereign Polyglot Core - Task 2476 (Software Architecture)
class Task2476Engine {
  static const int taskId = 2476;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'mitordnen';
  static const String praeteritum = 'ordnete mit';
  static const String perfekt = 'hat mitgeordnet';
  static const String arabicTranslation = 'مشاركة / تنسيق التصنيف (هندسة البرمجيات)';
  static const String ipaTranscription = '[mitˈˈɔʁdnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2476_mitordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review mitordnen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التصنيف في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
