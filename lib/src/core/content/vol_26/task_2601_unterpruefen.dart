// Sovereign Polyglot Core - Task 2601 (Clinical Diagnostics)
class Task2601Engine {
  static const int taskId = 2601;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'unterpruefen';
  static const String praeteritum = 'unterpruefte';
  static const String perfekt = 'hat unterprueft';
  static const String arabicTranslation = 'فحص / دعم التدقيق (التواصل الطبي)';
  static const String ipaTranscription = '[unterˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2601_unterpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung unterpruefen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التدقيق في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
