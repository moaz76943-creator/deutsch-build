// Sovereign Polyglot Core - Task 2803 (Clinical Diagnostics)
class Task2803Engine {
  static const int taskId = 2803;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'entziehen';
  static const String praeteritum = 'entzog';
  static const String perfekt = 'hat entzogen';
  static const String arabicTranslation = 'استخلاص / كشف الاستنتاج (التواصل الطبي)';
  static const String ipaTranscription = '[entˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2803_entziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung entziehen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف الاستنتاج في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
