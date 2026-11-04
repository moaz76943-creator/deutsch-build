// Sovereign Polyglot Core - Task 2340 (Software Architecture)
class Task2340Engine {
  static const int taskId = 2340;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'ueberhalten';
  static const String praeteritum = 'ueberhielt';
  static const String perfekt = 'hat ueberhalten';
  static const String arabicTranslation = 'مراجعة / نقل الالتزام (هندسة البرمجيات)';
  static const String ipaTranscription = '[ueberˈˈhaltn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2340_ueberhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review ueberhalten.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل الالتزام في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
