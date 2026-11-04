// Sovereign Polyglot Core - Task 2361 (Software Architecture)
class Task2361Engine {
  static const int taskId = 2361;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'unterschreiben';
  static const String praeteritum = 'unterschrieb';
  static const String perfekt = 'hat unterschrieben';
  static const String arabicTranslation = 'فحص / دعم التدوين (هندسة البرمجيات)';
  static const String ipaTranscription = '[unterˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2361_unterschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review unterschreiben.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التدوين في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
