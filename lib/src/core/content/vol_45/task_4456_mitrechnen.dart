// Sovereign Polyglot Core - Task 4456 (Supply Chain)
class Task4456Engine {
  static const int taskId = 4456;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'mitrechnen';
  static const String praeteritum = 'rechnete mit';
  static const String perfekt = 'hat mitgerechnet';
  static const String arabicTranslation = 'مشاركة / تنسيق التقدير (سلاسل الإمداد)';
  static const String ipaTranscription = '[mitˈˈʁɛçnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4456_mitrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale mitrechnen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التقدير في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
