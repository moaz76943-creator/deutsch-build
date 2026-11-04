// Sovereign Polyglot Core - Task 2801 (Clinical Diagnostics)
class Task2801Engine {
  static const int taskId = 2801;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'unterziehen';
  static const String praeteritum = 'unterzog';
  static const String perfekt = 'hat unterzogen';
  static const String arabicTranslation = 'فحص / دعم الاستنتاج (التواصل الطبي)';
  static const String ipaTranscription = '[unterˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2801_unterziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung unterziehen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم الاستنتاج في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
