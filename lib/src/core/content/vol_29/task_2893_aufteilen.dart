// Sovereign Polyglot Core - Task 2893 (Clinical Diagnostics)
class Task2893Engine {
  static const int taskId = 2893;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'aufteilen';
  static const String praeteritum = 'teilte auf';
  static const String perfekt = 'hat aufgeteilt';
  static const String arabicTranslation = 'رفع / فتح التقسيم (التواصل الطبي)';
  static const String ipaTranscription = '[aufˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2893_aufteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung aufteilen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التقسيم في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
