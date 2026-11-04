// Sovereign Polyglot Core - Task 2787 (Clinical Diagnostics)
class Task2787Engine {
  static const int taskId = 2787;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'umsprechen';
  static const String praeteritum = 'sprach um';
  static const String perfekt = 'hat umgesprochen';
  static const String arabicTranslation = 'إعادة هيكلة التخاطب (التواصل الطبي)';
  static const String ipaTranscription = '[umˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2787_umsprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung umsprechen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التخاطب في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
