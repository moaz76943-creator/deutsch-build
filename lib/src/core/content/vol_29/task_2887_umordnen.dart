// Sovereign Polyglot Core - Task 2887 (Clinical Diagnostics)
class Task2887Engine {
  static const int taskId = 2887;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'umordnen';
  static const String praeteritum = 'ordnete um';
  static const String perfekt = 'hat umgeordnet';
  static const String arabicTranslation = 'إعادة هيكلة التصنيف (التواصل الطبي)';
  static const String ipaTranscription = '[umˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2887_umordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung umordnen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التصنيف في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
