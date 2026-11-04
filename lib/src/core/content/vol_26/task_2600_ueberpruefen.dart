// Sovereign Polyglot Core - Task 2600 (Clinical Diagnostics)
class Task2600Engine {
  static const int taskId = 2600;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'ueberpruefen';
  static const String praeteritum = 'ueberpruefte';
  static const String perfekt = 'hat ueberprueft';
  static const String arabicTranslation = 'مراجعة / نقل التدقيق (التواصل الطبي)';
  static const String ipaTranscription = '[ueberˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2600_ueberpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung ueberpruefen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التدقيق في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
