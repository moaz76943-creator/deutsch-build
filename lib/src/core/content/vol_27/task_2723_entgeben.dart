// Sovereign Polyglot Core - Task 2723 (Clinical Diagnostics)
class Task2723Engine {
  static const int taskId = 2723;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'entgeben';
  static const String praeteritum = 'entgab';
  static const String perfekt = 'hat entgeben';
  static const String arabicTranslation = 'استخلاص / كشف التسليم (التواصل الطبي)';
  static const String ipaTranscription = '[entˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2723_entgeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung entgeben.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التسليم في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
