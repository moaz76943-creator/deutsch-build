// Sovereign Polyglot Core - Task 2705 (Clinical Diagnostics)
class Task2705Engine {
  static const int taskId = 2705;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'ernehmen';
  static const String praeteritum = 'ernahm';
  static const String perfekt = 'hat ernommen';
  static const String arabicTranslation = 'إنجاز / تحقيق الاستلام (التواصل الطبي)';
  static const String ipaTranscription = '[erˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2705_ernehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung ernehmen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق الاستلام في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
