// Sovereign Polyglot Core - Task 2180 (Software Architecture)
class Task2180Engine {
  static const int taskId = 2180;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'ueberplanen';
  static const String praeteritum = 'ueberplante';
  static const String perfekt = 'hat ueberplant';
  static const String arabicTranslation = 'مراجعة / نقل التخطيط (هندسة البرمجيات)';
  static const String ipaTranscription = '[ueberˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2180_ueberplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review ueberplanen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التخطيط في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
