// Sovereign Polyglot Core - Task 2458 (Software Architecture)
class Task2458Engine {
  static const int taskId = 2458;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'vorrechnen';
  static const String praeteritum = 'rechnete vor';
  static const String perfekt = 'hat vorgerechnet';
  static const String arabicTranslation = 'تقديم / تحضير التقدير (هندسة البرمجيات)';
  static const String ipaTranscription = '[vorˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2458_vorrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review vorrechnen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التقدير في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
