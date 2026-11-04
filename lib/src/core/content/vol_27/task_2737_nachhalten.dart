// Sovereign Polyglot Core - Task 2737 (Clinical Diagnostics)
class Task2737Engine {
  static const int taskId = 2737;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'nachhalten';
  static const String praeteritum = 'hielt nach';
  static const String perfekt = 'hat nachgehalten';
  static const String arabicTranslation = 'تدقيق / متابعة الالتزام (التواصل الطبي)';
  static const String ipaTranscription = '[nachˈˈhaltn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2737_nachhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung nachhalten.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة الالتزام في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
