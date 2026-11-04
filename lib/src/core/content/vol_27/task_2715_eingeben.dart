// Sovereign Polyglot Core - Task 2715 (Clinical Diagnostics)
class Task2715Engine {
  static const int taskId = 2715;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'eingeben';
  static const String praeteritum = 'gab ein';
  static const String perfekt = 'hat eingegeben';
  static const String arabicTranslation = 'إدراج / دمج التسليم (التواصل الطبي)';
  static const String ipaTranscription = '[einˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2715_eingeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung eingeben.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التسليم في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
