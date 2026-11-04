// Sovereign Polyglot Core - Task 2747 (Clinical Diagnostics)
class Task2747Engine {
  static const int taskId = 2747;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'umhalten';
  static const String praeteritum = 'hielt um';
  static const String perfekt = 'hat umgehalten';
  static const String arabicTranslation = 'إعادة هيكلة الالتزام (التواصل الطبي)';
  static const String ipaTranscription = '[umˈˈhaltn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2747_umhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung umhalten.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة الالتزام في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
