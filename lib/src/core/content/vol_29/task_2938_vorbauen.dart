// Sovereign Polyglot Core - Task 2938 (Clinical Diagnostics)
class Task2938Engine {
  static const int taskId = 2938;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'vorbauen';
  static const String praeteritum = 'baute vor';
  static const String perfekt = 'hat vorgebaut';
  static const String arabicTranslation = 'تقديم / تحضير التطوير (التواصل الطبي)';
  static const String ipaTranscription = '[vorˈˈbaʊ̯ən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2938_vorbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung vorbauen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التطوير في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
