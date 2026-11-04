// Sovereign Polyglot Core - Task 2907 (Clinical Diagnostics)
class Task2907Engine {
  static const int taskId = 2907;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'umteilen';
  static const String praeteritum = 'teilte um';
  static const String perfekt = 'hat umgeteilt';
  static const String arabicTranslation = 'إعادة هيكلة التقسيم (التواصل الطبي)';
  static const String ipaTranscription = '[umˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2907_umteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung umteilen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التقسيم في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
