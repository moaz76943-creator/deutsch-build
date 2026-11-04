// Sovereign Polyglot Core - Task 2336 (Software Architecture)
class Task2336Engine {
  static const int taskId = 2336;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'mithalten';
  static const String praeteritum = 'hielt mit';
  static const String perfekt = 'hat mitgehalten';
  static const String arabicTranslation = 'مشاركة / تنسيق الالتزام (هندسة البرمجيات)';
  static const String ipaTranscription = '[mitˈˈhaltn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2336_mithalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review mithalten.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق الالتزام في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
