// Sovereign Polyglot Core - Task 2909 (Clinical Diagnostics)
class Task2909Engine {
  static const int taskId = 2909;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'zusammenteilen';
  static const String praeteritum = 'teilte zusammen';
  static const String perfekt = 'hat zusammengeteilt';
  static const String arabicTranslation = 'تجميع / توحيد التقسيم (التواصل الطبي)';
  static const String ipaTranscription = '[zusammenˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2909_zusammenteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung zusammenteilen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التقسيم في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
