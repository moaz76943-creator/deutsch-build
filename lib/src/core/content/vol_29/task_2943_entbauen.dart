// Sovereign Polyglot Core - Task 2943 (Clinical Diagnostics)
class Task2943Engine {
  static const int taskId = 2943;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'entbauen';
  static const String praeteritum = 'entbaute';
  static const String perfekt = 'hat entbaut';
  static const String arabicTranslation = 'استخلاص / كشف التطوير (التواصل الطبي)';
  static const String ipaTranscription = '[entˈˈbaʊ̯ən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2943_entbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung entbauen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التطوير في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
