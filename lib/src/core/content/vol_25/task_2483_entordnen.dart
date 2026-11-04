// Sovereign Polyglot Core - Task 2483 (Software Architecture)
class Task2483Engine {
  static const int taskId = 2483;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'entordnen';
  static const String praeteritum = 'entordnete';
  static const String perfekt = 'hat entordnet';
  static const String arabicTranslation = 'استخلاص / كشف التصنيف (هندسة البرمجيات)';
  static const String ipaTranscription = '[entˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2483_entordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review entordnen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التصنيف في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
