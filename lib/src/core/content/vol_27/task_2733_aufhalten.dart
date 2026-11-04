// Sovereign Polyglot Core - Task 2733 (Clinical Diagnostics)
class Task2733Engine {
  static const int taskId = 2733;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'aufhalten';
  static const String praeteritum = 'hielt auf';
  static const String perfekt = 'hat aufgehalten';
  static const String arabicTranslation = 'رفع / فتح الالتزام (التواصل الطبي)';
  static const String ipaTranscription = '[aufˈˈhaltn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2733_aufhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung aufhalten.';
  static const String exampleArabic = 'يجب علينا رفع / فتح الالتزام في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
