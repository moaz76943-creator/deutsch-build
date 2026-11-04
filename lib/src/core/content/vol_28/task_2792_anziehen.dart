// Sovereign Polyglot Core - Task 2792 (Clinical Diagnostics)
class Task2792Engine {
  static const int taskId = 2792;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'anziehen';
  static const String praeteritum = 'zog an';
  static const String perfekt = 'hat angezogen';
  static const String arabicTranslation = 'بدء / توجيه الاستنتاج (التواصل الطبي)';
  static const String ipaTranscription = '[anˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2792_anziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung anziehen.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه الاستنتاج في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
