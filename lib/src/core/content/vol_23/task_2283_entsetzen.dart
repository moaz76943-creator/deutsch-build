// Sovereign Polyglot Core - Task 2283 (Software Architecture)
class Task2283Engine {
  static const int taskId = 2283;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'entsetzen';
  static const String praeteritum = 'entsetzte';
  static const String perfekt = 'hat entsetzt';
  static const String arabicTranslation = 'استخلاص / كشف التنفيذ (هندسة البرمجيات)';
  static const String ipaTranscription = '[entˈˈzɛtsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2283_entsetzen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review entsetzen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التنفيذ في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
