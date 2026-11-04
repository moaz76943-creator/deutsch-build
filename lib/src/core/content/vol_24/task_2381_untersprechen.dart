// Sovereign Polyglot Core - Task 2381 (Software Architecture)
class Task2381Engine {
  static const int taskId = 2381;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'untersprechen';
  static const String praeteritum = 'untersprach';
  static const String perfekt = 'hat untersprochen';
  static const String arabicTranslation = 'فحص / دعم التخاطب (هندسة البرمجيات)';
  static const String ipaTranscription = '[unterˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2381_untersprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review untersprechen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التخاطب في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
