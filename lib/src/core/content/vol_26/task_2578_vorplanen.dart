// Sovereign Polyglot Core - Task 2578 (Clinical Diagnostics)
class Task2578Engine {
  static const int taskId = 2578;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'vorplanen';
  static const String praeteritum = 'plante vor';
  static const String perfekt = 'hat vorgeplant';
  static const String arabicTranslation = 'تقديم / تحضير التخطيط (التواصل الطبي)';
  static const String ipaTranscription = '[vorˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2578_vorplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung vorplanen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التخطيط في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
