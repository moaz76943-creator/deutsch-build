// Sovereign Polyglot Core - Task 2584 (Clinical Diagnostics)
class Task2584Engine {
  static const int taskId = 2584;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'beplanen';
  static const String praeteritum = 'beplante';
  static const String perfekt = 'hat beplant';
  static const String arabicTranslation = 'تأكيد / تزويد التخطيط (التواصل الطبي)';
  static const String ipaTranscription = '[beˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2584_beplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung beplanen.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد التخطيط في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
