// Sovereign Polyglot Core - Task 2624 (Clinical Diagnostics)
class Task2624Engine {
  static const int taskId = 2624;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'bestellen';
  static const String praeteritum = 'bestellte';
  static const String perfekt = 'hat bestellt';
  static const String arabicTranslation = 'تأكيد / تزويد التنظيم (التواصل الطبي)';
  static const String ipaTranscription = '[beˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2624_bestellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung bestellen.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد التنظيم في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
