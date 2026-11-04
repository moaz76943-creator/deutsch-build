// Sovereign Polyglot Core - Task 2730 (Clinical Diagnostics)
class Task2730Engine {
  static const int taskId = 2730;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'festgeben';
  static const String praeteritum = 'gab fest';
  static const String perfekt = 'hat festgegeben';
  static const String arabicTranslation = 'تثبيت / إقرار التسليم (التواصل الطبي)';
  static const String ipaTranscription = '[festˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2730_festgeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung festgeben.';
  static const String exampleArabic = 'يجب علينا تثبيت / إقرار التسليم في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
