// Sovereign Polyglot Core - Task 2760 (Clinical Diagnostics)
class Task2760Engine {
  static const int taskId = 2760;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'ueberschreiben';
  static const String praeteritum = 'ueberschrieb';
  static const String perfekt = 'hat ueberschrieben';
  static const String arabicTranslation = 'مراجعة / نقل التدوين (التواصل الطبي)';
  static const String ipaTranscription = '[ueberˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2760_ueberschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung ueberschreiben.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التدوين في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
