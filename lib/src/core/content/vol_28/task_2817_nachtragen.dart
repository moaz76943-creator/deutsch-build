// Sovereign Polyglot Core - Task 2817 (Clinical Diagnostics)
class Task2817Engine {
  static const int taskId = 2817;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'nachtragen';
  static const String praeteritum = 'trug nach';
  static const String perfekt = 'hat nachgetragen';
  static const String arabicTranslation = 'تدقيق / متابعة المسؤولية (التواصل الطبي)';
  static const String ipaTranscription = '[nachˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2817_nachtragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung nachtragen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة المسؤولية في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
