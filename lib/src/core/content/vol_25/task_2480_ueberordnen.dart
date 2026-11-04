// Sovereign Polyglot Core - Task 2480 (Software Architecture)
class Task2480Engine {
  static const int taskId = 2480;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'ueberordnen';
  static const String praeteritum = 'ueberordnete';
  static const String perfekt = 'hat ueberordnet';
  static const String arabicTranslation = 'مراجعة / نقل التصنيف (هندسة البرمجيات)';
  static const String ipaTranscription = '[ueberˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2480_ueberordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review ueberordnen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التصنيف في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
