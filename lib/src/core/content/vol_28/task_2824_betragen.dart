// Sovereign Polyglot Core - Task 2824 (Clinical Diagnostics)
class Task2824Engine {
  static const int taskId = 2824;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'betragen';
  static const String praeteritum = 'betrug';
  static const String perfekt = 'hat betragen';
  static const String arabicTranslation = 'تأكيد / تزويد المسؤولية (التواصل الطبي)';
  static const String ipaTranscription = '[beˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2824_betragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung betragen.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد المسؤولية في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
