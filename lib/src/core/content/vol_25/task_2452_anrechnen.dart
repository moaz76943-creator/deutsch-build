// Sovereign Polyglot Core - Task 2452 (Software Architecture)
class Task2452Engine {
  static const int taskId = 2452;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'anrechnen';
  static const String praeteritum = 'rechnete an';
  static const String perfekt = 'hat angerechnet';
  static const String arabicTranslation = 'بدء / توجيه التقدير (هندسة البرمجيات)';
  static const String ipaTranscription = '[anˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2452_anrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review anrechnen.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه التقدير في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
