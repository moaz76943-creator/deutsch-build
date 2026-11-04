// Sovereign Polyglot Core - Task 2779 (Clinical Diagnostics)
class Task2779Engine {
  static const int taskId = 2779;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'zusprechen';
  static const String praeteritum = 'sprach zu';
  static const String perfekt = 'hat zugesprochen';
  static const String arabicTranslation = 'توجيه / إغلاق التخاطب (التواصل الطبي)';
  static const String ipaTranscription = '[zuˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2779_zusprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung zusprechen.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق التخاطب في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
