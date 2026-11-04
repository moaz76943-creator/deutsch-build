// Sovereign Polyglot Core - Task 2588 (Clinical Diagnostics)
class Task2588Engine {
  static const int taskId = 2588;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'weiterplanen';
  static const String praeteritum = 'plante weiter';
  static const String perfekt = 'hat weitergeplant';
  static const String arabicTranslation = 'مواصلة / تمرير التخطيط (التواصل الطبي)';
  static const String ipaTranscription = '[weiterˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2588_weiterplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung weiterplanen.';
  static const String exampleArabic = 'يجب علينا مواصلة / تمرير التخطيط في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
