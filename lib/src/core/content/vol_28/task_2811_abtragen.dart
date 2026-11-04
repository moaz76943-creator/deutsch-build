// Sovereign Polyglot Core - Task 2811 (Clinical Diagnostics)
class Task2811Engine {
  static const int taskId = 2811;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'abtragen';
  static const String praeteritum = 'trug ab';
  static const String perfekt = 'hat abgetragen';
  static const String arabicTranslation = 'فصل / إتمام المسؤولية (التواصل الطبي)';
  static const String ipaTranscription = '[abˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2811_abtragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung abtragen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام المسؤولية في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
