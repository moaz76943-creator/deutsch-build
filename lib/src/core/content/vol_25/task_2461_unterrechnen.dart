// Sovereign Polyglot Core - Task 2461 (Software Architecture)
class Task2461Engine {
  static const int taskId = 2461;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'unterrechnen';
  static const String praeteritum = 'unterrechnete';
  static const String perfekt = 'hat unterrechnet';
  static const String arabicTranslation = 'فحص / دعم التقدير (هندسة البرمجيات)';
  static const String ipaTranscription = '[unterˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2461_unterrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review unterrechnen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التقدير في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
