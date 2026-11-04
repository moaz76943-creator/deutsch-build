// Sovereign Polyglot Core - Task 2722 (Clinical Diagnostics)
class Task2722Engine {
  static const int taskId = 2722;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'vergeben';
  static const String praeteritum = 'vergab';
  static const String perfekt = 'hat vergeben';
  static const String arabicTranslation = 'توثيق / معالجة التسليم (التواصل الطبي)';
  static const String ipaTranscription = '[verˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2722_vergeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung vergeben.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة التسليم في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
