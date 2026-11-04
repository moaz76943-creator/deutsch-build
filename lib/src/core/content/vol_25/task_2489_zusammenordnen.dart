// Sovereign Polyglot Core - Task 2489 (Software Architecture)
class Task2489Engine {
  static const int taskId = 2489;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'zusammenordnen';
  static const String praeteritum = 'ordnete zusammen';
  static const String perfekt = 'hat zusammengeordnet';
  static const String arabicTranslation = 'تجميع / توحيد التصنيف (هندسة البرمجيات)';
  static const String ipaTranscription = '[zusammenˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2489_zusammenordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review zusammenordnen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التصنيف في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
