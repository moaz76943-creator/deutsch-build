// Sovereign Polyglot Core - Task 2763 (Clinical Diagnostics)
class Task2763Engine {
  static const int taskId = 2763;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'entschreiben';
  static const String praeteritum = 'entschrieb';
  static const String perfekt = 'hat entschrieben';
  static const String arabicTranslation = 'استخلاص / كشف التدوين (التواصل الطبي)';
  static const String ipaTranscription = '[entˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2763_entschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung entschreiben.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التدوين في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
