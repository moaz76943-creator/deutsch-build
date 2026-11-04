// Sovereign Polyglot Core - Task 2500 (Software Architecture)
class Task2500Engine {
  static const int taskId = 2500;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'ueberteilen';
  static const String praeteritum = 'ueberteilte';
  static const String perfekt = 'hat ueberteilt';
  static const String arabicTranslation = 'مراجعة / نقل التقسيم (هندسة البرمجيات)';
  static const String ipaTranscription = '[ueberˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2500_ueberteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review ueberteilen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التقسيم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
