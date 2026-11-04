// Sovereign Polyglot Core - Task 2855 (Clinical Diagnostics)
class Task2855Engine {
  static const int taskId = 2855;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'einrechnen';
  static const String praeteritum = 'rechnete ein';
  static const String perfekt = 'hat eingerechnet';
  static const String arabicTranslation = 'إدراج / دمج التقدير (التواصل الطبي)';
  static const String ipaTranscription = '[einˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2855_einrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung einrechnen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التقدير في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
