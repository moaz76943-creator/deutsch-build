// Sovereign Polyglot Core - Task 2724 (Clinical Diagnostics)
class Task2724Engine {
  static const int taskId = 2724;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'begeben';
  static const String praeteritum = 'begab';
  static const String perfekt = 'hat begeben';
  static const String arabicTranslation = 'تأكيد / تزويد التسليم (التواصل الطبي)';
  static const String ipaTranscription = '[beˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2724_begeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung begeben.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد التسليم في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
