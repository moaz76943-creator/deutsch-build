// Sovereign Polyglot Core - Task 2891 (Clinical Diagnostics)
class Task2891Engine {
  static const int taskId = 2891;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'abteilen';
  static const String praeteritum = 'teilte ab';
  static const String perfekt = 'hat abgeteilt';
  static const String arabicTranslation = 'فصل / إتمام التقسيم (التواصل الطبي)';
  static const String ipaTranscription = '[abˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2891_abteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung abteilen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التقسيم في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
