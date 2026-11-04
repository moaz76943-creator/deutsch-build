// Sovereign Polyglot Core - Task 2738 (Clinical Diagnostics)
class Task2738Engine {
  static const int taskId = 2738;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'vorhalten';
  static const String praeteritum = 'hielt vor';
  static const String perfekt = 'hat vorgehalten';
  static const String arabicTranslation = 'تقديم / تحضير الالتزام (التواصل الطبي)';
  static const String ipaTranscription = '[vorˈˈhaltn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2738_vorhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung vorhalten.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير الالتزام في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
