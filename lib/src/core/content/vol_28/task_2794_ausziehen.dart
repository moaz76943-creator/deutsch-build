// Sovereign Polyglot Core - Task 2794 (Clinical Diagnostics)
class Task2794Engine {
  static const int taskId = 2794;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'ausziehen';
  static const String praeteritum = 'zog aus';
  static const String perfekt = 'hat ausgezogen';
  static const String arabicTranslation = 'توسيع / استخراج الاستنتاج (التواصل الطبي)';
  static const String ipaTranscription = '[ausˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2794_ausziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung ausziehen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج الاستنتاج في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
