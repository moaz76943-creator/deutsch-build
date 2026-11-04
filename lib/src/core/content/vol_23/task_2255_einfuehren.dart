// Sovereign Polyglot Core - Task 2255 (Software Architecture)
class Task2255Engine {
  static const int taskId = 2255;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'einfuehren';
  static const String praeteritum = 'fuehrte ein';
  static const String perfekt = 'hat eingefuehrt';
  static const String arabicTranslation = 'إدراج / دمج الإدارة (هندسة البرمجيات)';
  static const String ipaTranscription = '[einˈˈfyːʁən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2255_einfuehren.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review einfuehren.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج الإدارة في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
