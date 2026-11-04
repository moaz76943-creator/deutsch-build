// Sovereign Polyglot Core - Task 4388 (Supply Chain)
class Task4388Engine {
  static const int taskId = 4388;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'weitersprechen';
  static const String praeteritum = 'sprach weiter';
  static const String perfekt = 'hat weitergesprochen';
  static const String arabicTranslation = 'مواصلة / تمرير التخاطب (سلاسل الإمداد)';
  static const String ipaTranscription = '[weiterˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4388_weitersprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale weitersprechen.';
  static const String exampleArabic = 'يجب علينا مواصلة / تمرير التخاطب في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
