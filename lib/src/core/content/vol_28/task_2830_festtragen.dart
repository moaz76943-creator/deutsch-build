// Sovereign Polyglot Core - Task 2830 (Clinical Diagnostics)
class Task2830Engine {
  static const int taskId = 2830;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'festtragen';
  static const String praeteritum = 'trug fest';
  static const String perfekt = 'hat festgetragen';
  static const String arabicTranslation = 'تثبيت / إقرار المسؤولية (التواصل الطبي)';
  static const String ipaTranscription = '[festˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2830_festtragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung festtragen.';
  static const String exampleArabic = 'يجب علينا تثبيت / إقرار المسؤولية في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
