// Sovereign Polyglot Core - Task 2469 (Software Architecture)
class Task2469Engine {
  static const int taskId = 2469;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'zusammenrechnen';
  static const String praeteritum = 'rechnete zusammen';
  static const String perfekt = 'hat zusammengerechnet';
  static const String arabicTranslation = 'تجميع / توحيد التقدير (هندسة البرمجيات)';
  static const String ipaTranscription = '[zusammenˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2469_zusammenrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review zusammenrechnen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التقدير في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
