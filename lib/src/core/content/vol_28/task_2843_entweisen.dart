// Sovereign Polyglot Core - Task 2843 (Clinical Diagnostics)
class Task2843Engine {
  static const int taskId = 2843;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'entweisen';
  static const String praeteritum = 'entwies';
  static const String perfekt = 'hat entwiesen';
  static const String arabicTranslation = 'استخلاص / كشف التوجيه (التواصل الطبي)';
  static const String ipaTranscription = '[entˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2843_entweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung entweisen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التوجيه في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
