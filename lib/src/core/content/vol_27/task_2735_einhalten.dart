// Sovereign Polyglot Core - Task 2735 (Clinical Diagnostics)
class Task2735Engine {
  static const int taskId = 2735;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'einhalten';
  static const String praeteritum = 'hielt ein';
  static const String perfekt = 'hat eingehalten';
  static const String arabicTranslation = 'إدراج / دمج الالتزام (التواصل الطبي)';
  static const String ipaTranscription = '[einˈˈhaltn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2735_einhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung einhalten.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج الالتزام في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
