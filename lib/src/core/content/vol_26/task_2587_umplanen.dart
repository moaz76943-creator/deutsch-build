// Sovereign Polyglot Core - Task 2587 (Clinical Diagnostics)
class Task2587Engine {
  static const int taskId = 2587;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'umplanen';
  static const String praeteritum = 'plante um';
  static const String perfekt = 'hat umgeplant';
  static const String arabicTranslation = 'إعادة هيكلة التخطيط (التواصل الطبي)';
  static const String ipaTranscription = '[umˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2587_umplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung umplanen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التخطيط في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
