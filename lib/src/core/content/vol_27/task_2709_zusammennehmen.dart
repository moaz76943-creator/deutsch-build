// Sovereign Polyglot Core - Task 2709 (Clinical Diagnostics)
class Task2709Engine {
  static const int taskId = 2709;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'zusammennehmen';
  static const String praeteritum = 'nahm zusammen';
  static const String perfekt = 'hat zusammengenommen';
  static const String arabicTranslation = 'تجميع / توحيد الاستلام (التواصل الطبي)';
  static const String ipaTranscription = '[zusammenˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2709_zusammennehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung zusammennehmen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد الاستلام في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
