// Sovereign Polyglot Core - Task 2627 (Clinical Diagnostics)
class Task2627Engine {
  static const int taskId = 2627;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'umstellen';
  static const String praeteritum = 'stellte um';
  static const String perfekt = 'hat umgestellt';
  static const String arabicTranslation = 'إعادة هيكلة التنظيم (التواصل الطبي)';
  static const String ipaTranscription = '[umˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2627_umstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung umstellen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التنظيم في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
