// Sovereign Polyglot Core - Task 2441 (Software Architecture)
class Task2441Engine {
  static const int taskId = 2441;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'unterweisen';
  static const String praeteritum = 'unterwies';
  static const String perfekt = 'hat unterwiesen';
  static const String arabicTranslation = 'فحص / دعم التوجيه (هندسة البرمجيات)';
  static const String ipaTranscription = '[unterˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2441_unterweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review unterweisen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التوجيه في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
