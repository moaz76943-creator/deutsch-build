// Sovereign Polyglot Core - Task 2945 (Clinical Diagnostics)
class Task2945Engine {
  static const int taskId = 2945;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'erbauen';
  static const String praeteritum = 'erbaute';
  static const String perfekt = 'hat erbaut';
  static const String arabicTranslation = 'إنجاز / تحقيق التطوير (التواصل الطبي)';
  static const String ipaTranscription = '[erˈˈbaʊ̯ən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2945_erbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung erbauen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التطوير في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
