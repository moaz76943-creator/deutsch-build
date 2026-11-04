// Sovereign Polyglot Core - Task 4777 (Quality Assurance)
class Task4777Engine {
  static const int taskId = 4777;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'nachsprechen';
  static const String praeteritum = 'sprach nach';
  static const String perfekt = 'hat nachgesprochen';
  static const String arabicTranslation = 'تدقيق / متابعة التخاطب (ضمان الجودة)';
  static const String ipaTranscription = '[nachˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4777_nachsprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess nachsprechen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التخاطب في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
