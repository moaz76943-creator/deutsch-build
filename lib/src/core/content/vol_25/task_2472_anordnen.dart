// Sovereign Polyglot Core - Task 2472 (Software Architecture)
class Task2472Engine {
  static const int taskId = 2472;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'anordnen';
  static const String praeteritum = 'ordnete an';
  static const String perfekt = 'hat angeordnet';
  static const String arabicTranslation = 'بدء / توجيه التصنيف (هندسة البرمجيات)';
  static const String ipaTranscription = '[anˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2472_anordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review anordnen.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه التصنيف في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
