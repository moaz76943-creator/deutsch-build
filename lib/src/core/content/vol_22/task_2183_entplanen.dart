// Sovereign Polyglot Core - Task 2183 (Software Architecture)
class Task2183Engine {
  static const int taskId = 2183;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'entplanen';
  static const String praeteritum = 'entplante';
  static const String perfekt = 'hat entplant';
  static const String arabicTranslation = 'استخلاص / كشف التخطيط (هندسة البرمجيات)';
  static const String ipaTranscription = '[entˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2183_entplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review entplanen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التخطيط في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
