// Sovereign Polyglot Core - Task 2420 (Software Architecture)
class Task2420Engine {
  static const int taskId = 2420;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'uebertragen';
  static const String praeteritum = 'uebertrug';
  static const String perfekt = 'hat uebertragen';
  static const String arabicTranslation = 'مراجعة / نقل المسؤولية (هندسة البرمجيات)';
  static const String ipaTranscription = '[ueberˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2420_uebertragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review uebertragen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل المسؤولية في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
