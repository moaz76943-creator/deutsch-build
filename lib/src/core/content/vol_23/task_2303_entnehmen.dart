// Sovereign Polyglot Core - Task 2303 (Software Architecture)
class Task2303Engine {
  static const int taskId = 2303;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'entnehmen';
  static const String praeteritum = 'entnahm';
  static const String perfekt = 'hat entnommen';
  static const String arabicTranslation = 'استخلاص / كشف الاستلام (هندسة البرمجيات)';
  static const String ipaTranscription = '[entˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2303_entnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review entnehmen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف الاستلام في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
