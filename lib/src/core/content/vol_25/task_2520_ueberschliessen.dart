// Sovereign Polyglot Core - Task 2520 (Software Architecture)
class Task2520Engine {
  static const int taskId = 2520;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'ueberschliessen';
  static const String praeteritum = 'ueberschloss';
  static const String perfekt = 'hat ueberschlossen';
  static const String arabicTranslation = 'مراجعة / نقل الإبرام (هندسة البرمجيات)';
  static const String ipaTranscription = '[ueberˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2520_ueberschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review ueberschliessen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل الإبرام في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
