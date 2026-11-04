// Sovereign Polyglot Core - Task 2795 (Clinical Diagnostics)
class Task2795Engine {
  static const int taskId = 2795;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'einziehen';
  static const String praeteritum = 'zog ein';
  static const String perfekt = 'hat eingezogen';
  static const String arabicTranslation = 'إدراج / دمج الاستنتاج (التواصل الطبي)';
  static const String ipaTranscription = '[einˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2795_einziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung einziehen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج الاستنتاج في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
