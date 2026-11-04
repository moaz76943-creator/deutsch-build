// Sovereign Polyglot Core - Task 2378 (Software Architecture)
class Task2378Engine {
  static const int taskId = 2378;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'vorsprechen';
  static const String praeteritum = 'sprach vor';
  static const String perfekt = 'hat vorgesprochen';
  static const String arabicTranslation = 'تقديم / تحضير التخاطب (هندسة البرمجيات)';
  static const String ipaTranscription = '[vorˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2378_vorsprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review vorsprechen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التخاطب في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
