// Sovereign Polyglot Core - Task 2380 (Software Architecture)
class Task2380Engine {
  static const int taskId = 2380;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'uebersprechen';
  static const String praeteritum = 'uebersprach';
  static const String perfekt = 'hat uebersprochen';
  static const String arabicTranslation = 'مراجعة / نقل التخاطب (هندسة البرمجيات)';
  static const String ipaTranscription = '[ueberˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2380_uebersprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review uebersprechen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التخاطب في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
