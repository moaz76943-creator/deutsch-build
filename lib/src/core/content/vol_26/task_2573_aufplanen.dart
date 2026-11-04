// Sovereign Polyglot Core - Task 2573 (Clinical Diagnostics)
class Task2573Engine {
  static const int taskId = 2573;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'aufplanen';
  static const String praeteritum = 'plante auf';
  static const String perfekt = 'hat aufgeplant';
  static const String arabicTranslation = 'رفع / فتح التخطيط (التواصل الطبي)';
  static const String ipaTranscription = '[aufˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2573_aufplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung aufplanen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التخطيط في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
