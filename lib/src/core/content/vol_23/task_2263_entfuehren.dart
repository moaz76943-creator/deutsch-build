// Sovereign Polyglot Core - Task 2263 (Software Architecture)
class Task2263Engine {
  static const int taskId = 2263;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'entfuehren';
  static const String praeteritum = 'entfuehrte';
  static const String perfekt = 'hat entfuehrt';
  static const String arabicTranslation = 'استخلاص / كشف الإدارة (هندسة البرمجيات)';
  static const String ipaTranscription = '[entˈˈfyːʁən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2263_entfuehren.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review entfuehren.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف الإدارة في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
