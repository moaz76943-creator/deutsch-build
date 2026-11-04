// Sovereign Polyglot Core - Task 2777 (Clinical Diagnostics)
class Task2777Engine {
  static const int taskId = 2777;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'nachsprechen';
  static const String praeteritum = 'sprach nach';
  static const String perfekt = 'hat nachgesprochen';
  static const String arabicTranslation = 'تدقيق / متابعة التخاطب (التواصل الطبي)';
  static const String ipaTranscription = '[nachˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2777_nachsprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung nachsprechen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التخاطب في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
