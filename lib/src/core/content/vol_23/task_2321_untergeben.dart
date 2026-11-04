// Sovereign Polyglot Core - Task 2321 (Software Architecture)
class Task2321Engine {
  static const int taskId = 2321;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'untergeben';
  static const String praeteritum = 'untergab';
  static const String perfekt = 'hat untergeben';
  static const String arabicTranslation = 'فحص / دعم التسليم (هندسة البرمجيات)';
  static const String ipaTranscription = '[unterˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2321_untergeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review untergeben.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التسليم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
