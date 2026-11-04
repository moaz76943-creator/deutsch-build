// Sovereign Polyglot Core - Task 2813 (Clinical Diagnostics)
class Task2813Engine {
  static const int taskId = 2813;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'auftragen';
  static const String praeteritum = 'trug auf';
  static const String perfekt = 'hat aufgetragen';
  static const String arabicTranslation = 'رفع / فتح المسؤولية (التواصل الطبي)';
  static const String ipaTranscription = '[aufˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2813_auftragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung auftragen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح المسؤولية في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
