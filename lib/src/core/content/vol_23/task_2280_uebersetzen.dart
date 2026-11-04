// Sovereign Polyglot Core - Task 2280 (Software Architecture)
class Task2280Engine {
  static const int taskId = 2280;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'uebersetzen';
  static const String praeteritum = 'uebersetzte';
  static const String perfekt = 'hat uebersetzt';
  static const String arabicTranslation = 'مراجعة / نقل التنفيذ (هندسة البرمجيات)';
  static const String ipaTranscription = '[ueberˈˈzɛtsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2280_uebersetzen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review uebersetzen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التنفيذ في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
