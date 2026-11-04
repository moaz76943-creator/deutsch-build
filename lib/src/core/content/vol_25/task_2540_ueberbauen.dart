// Sovereign Polyglot Core - Task 2540 (Software Architecture)
class Task2540Engine {
  static const int taskId = 2540;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'ueberbauen';
  static const String praeteritum = 'ueberbaute';
  static const String perfekt = 'hat ueberbaut';
  static const String arabicTranslation = 'مراجعة / نقل التطوير (هندسة البرمجيات)';
  static const String ipaTranscription = '[ueberˈˈbaʊ̯ən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2540_ueberbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review ueberbauen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التطوير في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
