// Sovereign Polyglot Core - Task 2867 (Clinical Diagnostics)
class Task2867Engine {
  static const int taskId = 2867;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'umrechnen';
  static const String praeteritum = 'rechnete um';
  static const String perfekt = 'hat umgerechnet';
  static const String arabicTranslation = 'إعادة هيكلة التقدير (التواصل الطبي)';
  static const String ipaTranscription = '[umˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2867_umrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung umrechnen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التقدير في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
