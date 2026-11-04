// Sovereign Polyglot Core - Task 2429 (Software Architecture)
class Task2429Engine {
  static const int taskId = 2429;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'zusammentragen';
  static const String praeteritum = 'trug zusammen';
  static const String perfekt = 'hat zusammengetragen';
  static const String arabicTranslation = 'تجميع / توحيد المسؤولية (هندسة البرمجيات)';
  static const String ipaTranscription = '[zusammenˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2429_zusammentragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review zusammentragen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد المسؤولية في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
