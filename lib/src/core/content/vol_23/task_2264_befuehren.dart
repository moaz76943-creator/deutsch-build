// Sovereign Polyglot Core - Task 2264 (Software Architecture)
class Task2264Engine {
  static const int taskId = 2264;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'befuehren';
  static const String praeteritum = 'befuehrte';
  static const String perfekt = 'hat befuehrt';
  static const String arabicTranslation = 'تأكيد / تزويد الإدارة (هندسة البرمجيات)';
  static const String ipaTranscription = '[beˈˈfyːʁən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2264_befuehren.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review befuehren.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد الإدارة في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
