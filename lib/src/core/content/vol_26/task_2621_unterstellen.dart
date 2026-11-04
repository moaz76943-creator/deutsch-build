// Sovereign Polyglot Core - Task 2621 (Clinical Diagnostics)
class Task2621Engine {
  static const int taskId = 2621;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'unterstellen';
  static const String praeteritum = 'unterstellte';
  static const String perfekt = 'hat unterstellt';
  static const String arabicTranslation = 'فحص / دعم التنظيم (التواصل الطبي)';
  static const String ipaTranscription = '[unterˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2621_unterstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung unterstellen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التنظيم في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
