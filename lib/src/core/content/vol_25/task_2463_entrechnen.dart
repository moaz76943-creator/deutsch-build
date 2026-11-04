// Sovereign Polyglot Core - Task 2463 (Software Architecture)
class Task2463Engine {
  static const int taskId = 2463;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'entrechnen';
  static const String praeteritum = 'entrechnete';
  static const String perfekt = 'hat entrechnet';
  static const String arabicTranslation = 'استخلاص / كشف التقدير (هندسة البرمجيات)';
  static const String ipaTranscription = '[entˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2463_entrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review entrechnen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التقدير في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
