// Sovereign Polyglot Core - Task 4476 (Supply Chain)
class Task4476Engine {
  static const int taskId = 4476;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'mitordnen';
  static const String praeteritum = 'ordnete mit';
  static const String perfekt = 'hat mitgeordnet';
  static const String arabicTranslation = 'مشاركة / تنسيق التصنيف (سلاسل الإمداد)';
  static const String ipaTranscription = '[mitˈˈɔʁdnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4476_mitordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale mitordnen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التصنيف في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
