// Sovereign Polyglot Core - Task 2602 (Clinical Diagnostics)
class Task2602Engine {
  static const int taskId = 2602;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'verpruefen';
  static const String praeteritum = 'verpruefte';
  static const String perfekt = 'hat verprueft';
  static const String arabicTranslation = 'توثيق / معالجة التدقيق (التواصل الطبي)';
  static const String ipaTranscription = '[verˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2602_verpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung verpruefen.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة التدقيق في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
