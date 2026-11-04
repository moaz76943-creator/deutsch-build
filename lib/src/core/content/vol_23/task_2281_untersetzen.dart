// Sovereign Polyglot Core - Task 2281 (Software Architecture)
class Task2281Engine {
  static const int taskId = 2281;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'untersetzen';
  static const String praeteritum = 'untersetzte';
  static const String perfekt = 'hat untersetzt';
  static const String arabicTranslation = 'فحص / دعم التنفيذ (هندسة البرمجيات)';
  static const String ipaTranscription = '[unterˈˈzɛtsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2281_untersetzen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review untersetzen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التنفيذ في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
