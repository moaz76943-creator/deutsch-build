// Sovereign Polyglot Core - Task 2782 (Clinical Diagnostics)
class Task2782Engine {
  static const int taskId = 2782;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'versprechen';
  static const String praeteritum = 'versprach';
  static const String perfekt = 'hat versprochen';
  static const String arabicTranslation = 'توثيق / معالجة التخاطب (التواصل الطبي)';
  static const String ipaTranscription = '[verˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2782_versprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung versprechen.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة التخاطب في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
