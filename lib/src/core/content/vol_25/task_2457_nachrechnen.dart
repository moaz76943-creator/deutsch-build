// Sovereign Polyglot Core - Task 2457 (Software Architecture)
class Task2457Engine {
  static const int taskId = 2457;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'nachrechnen';
  static const String praeteritum = 'rechnete nach';
  static const String perfekt = 'hat nachgerechnet';
  static const String arabicTranslation = 'تدقيق / متابعة التقدير (هندسة البرمجيات)';
  static const String ipaTranscription = '[nachˈˈʁɛçnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2457_nachrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review nachrechnen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التقدير في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
