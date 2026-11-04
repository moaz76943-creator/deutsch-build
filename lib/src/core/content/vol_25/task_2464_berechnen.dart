// Sovereign Polyglot Core - Task 2464 (Software Architecture)
class Task2464Engine {
  static const int taskId = 2464;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'berechnen';
  static const String praeteritum = 'berechnete';
  static const String perfekt = 'hat berechnet';
  static const String arabicTranslation = 'تأكيد / تزويد التقدير (هندسة البرمجيات)';
  static const String ipaTranscription = '[beˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2464_berechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review berechnen.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد التقدير في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
