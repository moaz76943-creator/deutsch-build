// Sovereign Polyglot Core - Task 2711 (Clinical Diagnostics)
class Task2711Engine {
  static const int taskId = 2711;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'abgeben';
  static const String praeteritum = 'gab ab';
  static const String perfekt = 'hat abgegeben';
  static const String arabicTranslation = 'فصل / إتمام التسليم (التواصل الطبي)';
  static const String ipaTranscription = '[abˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2711_abgeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung abgeben.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التسليم في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
