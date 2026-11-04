// Sovereign Polyglot Core - Task 2829 (Clinical Diagnostics)
class Task2829Engine {
  static const int taskId = 2829;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'zusammentragen';
  static const String praeteritum = 'trug zusammen';
  static const String perfekt = 'hat zusammengetragen';
  static const String arabicTranslation = 'تجميع / توحيد المسؤولية (التواصل الطبي)';
  static const String ipaTranscription = '[zusammenˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2829_zusammentragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung zusammentragen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد المسؤولية في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
