// Sovereign Polyglot Core - Task 4376 (Supply Chain)
class Task4376Engine {
  static const int taskId = 4376;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'mitsprechen';
  static const String praeteritum = 'sprach mit';
  static const String perfekt = 'hat mitgesprochen';
  static const String arabicTranslation = 'مشاركة / تنسيق التخاطب (سلاسل الإمداد)';
  static const String ipaTranscription = '[mitˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4376_mitsprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale mitsprechen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التخاطب في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
