// Sovereign Polyglot Core - Task 2899 (Clinical Diagnostics)
class Task2899Engine {
  static const int taskId = 2899;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'zuteilen';
  static const String praeteritum = 'teilte zu';
  static const String perfekt = 'hat zugeteilt';
  static const String arabicTranslation = 'توجيه / إغلاق التقسيم (التواصل الطبي)';
  static const String ipaTranscription = '[zuˈˈtaɪ̯lən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2899_zuteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung zuteilen.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق التقسيم في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
