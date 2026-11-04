// Sovereign Polyglot Core - Task 2831 (Clinical Diagnostics)
class Task2831Engine {
  static const int taskId = 2831;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'abweisen';
  static const String praeteritum = 'wies ab';
  static const String perfekt = 'hat abgewiesen';
  static const String arabicTranslation = 'فصل / إتمام التوجيه (التواصل الطبي)';
  static const String ipaTranscription = '[abˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2831_abweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung abweisen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التوجيه في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
