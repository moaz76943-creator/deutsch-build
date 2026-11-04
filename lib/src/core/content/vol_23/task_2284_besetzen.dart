// Sovereign Polyglot Core - Task 2284 (Software Architecture)
class Task2284Engine {
  static const int taskId = 2284;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'besetzen';
  static const String praeteritum = 'besetzte';
  static const String perfekt = 'hat besetzt';
  static const String arabicTranslation = 'تأكيد / تزويد التنفيذ (هندسة البرمجيات)';
  static const String ipaTranscription = '[beˈˈzɛtsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2284_besetzen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review besetzen.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد التنفيذ في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
