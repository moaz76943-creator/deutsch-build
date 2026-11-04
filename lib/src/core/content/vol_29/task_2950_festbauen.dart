// Sovereign Polyglot Core - Task 2950 (Clinical Diagnostics)
class Task2950Engine {
  static const int taskId = 2950;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'festbauen';
  static const String praeteritum = 'baute fest';
  static const String perfekt = 'hat festgebaut';
  static const String arabicTranslation = 'تثبيت / إقرار التطوير (التواصل الطبي)';
  static const String ipaTranscription = '[festˈˈbaʊ̯ən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2950_festbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung festbauen.';
  static const String exampleArabic = 'يجب علينا تثبيت / إقرار التطوير في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
