// Sovereign Polyglot Core - Task 2898 (Clinical Diagnostics)
class Task2898Engine {
  static const int taskId = 2898;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'vorteilen';
  static const String praeteritum = 'teilte vor';
  static const String perfekt = 'hat vorgeteilt';
  static const String arabicTranslation = 'تقديم / تحضير التقسيم (التواصل الطبي)';
  static const String ipaTranscription = '[vorˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2898_vorteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung vorteilen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التقسيم في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
