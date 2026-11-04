// Sovereign Polyglot Core - Task 2727 (Clinical Diagnostics)
class Task2727Engine {
  static const int taskId = 2727;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'umgeben';
  static const String praeteritum = 'gab um';
  static const String perfekt = 'hat umgegeben';
  static const String arabicTranslation = 'إعادة هيكلة التسليم (التواصل الطبي)';
  static const String ipaTranscription = '[umˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2727_umgeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung umgeben.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التسليم في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
