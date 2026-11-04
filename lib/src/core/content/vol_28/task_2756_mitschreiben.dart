// Sovereign Polyglot Core - Task 2756 (Clinical Diagnostics)
class Task2756Engine {
  static const int taskId = 2756;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'mitschreiben';
  static const String praeteritum = 'schrieb mit';
  static const String perfekt = 'hat mitgeschrieben';
  static const String arabicTranslation = 'مشاركة / تنسيق التدوين (التواصل الطبي)';
  static const String ipaTranscription = '[mitˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2756_mitschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung mitschreiben.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التدوين في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
