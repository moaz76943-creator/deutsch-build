// Sovereign Polyglot Core - Task 2260 (Software Architecture)
class Task2260Engine {
  static const int taskId = 2260;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'ueberfuehren';
  static const String praeteritum = 'ueberfuehrte';
  static const String perfekt = 'hat ueberfuehrt';
  static const String arabicTranslation = 'مراجعة / نقل الإدارة (هندسة البرمجيات)';
  static const String ipaTranscription = '[ueberˈˈfyːʁən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2260_ueberfuehren.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review ueberfuehren.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل الإدارة في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
