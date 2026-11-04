// Sovereign Polyglot Core - Task 2783 (Clinical Diagnostics)
class Task2783Engine {
  static const int taskId = 2783;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'entsprechen';
  static const String praeteritum = 'entsprach';
  static const String perfekt = 'hat entsprochen';
  static const String arabicTranslation = 'استخلاص / كشف التخاطب (التواصل الطبي)';
  static const String ipaTranscription = '[entˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2783_entsprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung entsprechen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التخاطب في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
