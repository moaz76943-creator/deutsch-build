// Sovereign Polyglot Core - Task 3977 (Financial Auditing)
class Task3977Engine {
  static const int taskId = 3977;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'nachsprechen';
  static const String praeteritum = 'sprach nach';
  static const String perfekt = 'hat nachgesprochen';
  static const String arabicTranslation = 'تدقيق / متابعة التخاطب (التدقيق المالي)';
  static const String ipaTranscription = '[nachˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3977_nachsprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung nachsprechen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التخاطب في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
