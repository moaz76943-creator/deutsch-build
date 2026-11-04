// Sovereign Polyglot Core - Task 2944 (Clinical Diagnostics)
class Task2944Engine {
  static const int taskId = 2944;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'bebauen';
  static const String praeteritum = 'bebaute';
  static const String perfekt = 'hat bebaut';
  static const String arabicTranslation = 'تأكيد / تزويد التطوير (التواصل الطبي)';
  static const String ipaTranscription = '[beˈˈbaʊ̯ən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2944_bebauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung bebauen.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد التطوير في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
