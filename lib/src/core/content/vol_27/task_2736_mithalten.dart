// Sovereign Polyglot Core - Task 2736 (Clinical Diagnostics)
class Task2736Engine {
  static const int taskId = 2736;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'mithalten';
  static const String praeteritum = 'hielt mit';
  static const String perfekt = 'hat mitgehalten';
  static const String arabicTranslation = 'مشاركة / تنسيق الالتزام (التواصل الطبي)';
  static const String ipaTranscription = '[mitˈˈhaltn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2736_mithalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung mithalten.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق الالتزام في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
