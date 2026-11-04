// Sovereign Polyglot Core - Task 2894 (Clinical Diagnostics)
class Task2894Engine {
  static const int taskId = 2894;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'austeilen';
  static const String praeteritum = 'teilte aus';
  static const String perfekt = 'hat ausgeteilt';
  static const String arabicTranslation = 'توسيع / استخراج التقسيم (التواصل الطبي)';
  static const String ipaTranscription = '[ausˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2894_austeilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung austeilen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التقسيم في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
