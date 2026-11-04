// Sovereign Polyglot Core - Task 2492 (Software Architecture)
class Task2492Engine {
  static const int taskId = 2492;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'anteilen';
  static const String praeteritum = 'teilte an';
  static const String perfekt = 'hat angeteilt';
  static const String arabicTranslation = 'بدء / توجيه التقسيم (هندسة البرمجيات)';
  static const String ipaTranscription = '[anˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2492_anteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review anteilen.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه التقسيم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
