// Sovereign Polyglot Core - Task 2386 (Software Architecture)
class Task2386Engine {
  static const int taskId = 2386;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'durchsprechen';
  static const String praeteritum = 'sprach durch';
  static const String perfekt = 'hat durchgesprochen';
  static const String arabicTranslation = 'إتمام شامل التخاطب (هندسة البرمجيات)';
  static const String ipaTranscription = '[durchˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2386_durchsprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review durchsprechen.';
  static const String exampleArabic = 'يجب علينا إتمام شامل التخاطب في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
