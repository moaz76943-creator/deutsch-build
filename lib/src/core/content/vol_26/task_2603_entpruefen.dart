// Sovereign Polyglot Core - Task 2603 (Clinical Diagnostics)
class Task2603Engine {
  static const int taskId = 2603;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'entpruefen';
  static const String praeteritum = 'entpruefte';
  static const String perfekt = 'hat entprueft';
  static const String arabicTranslation = 'استخلاص / كشف التدقيق (التواصل الطبي)';
  static const String ipaTranscription = '[entˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2603_entpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung entpruefen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التدقيق في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
