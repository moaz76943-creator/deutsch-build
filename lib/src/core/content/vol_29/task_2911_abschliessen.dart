// Sovereign Polyglot Core - Task 2911 (Clinical Diagnostics)
class Task2911Engine {
  static const int taskId = 2911;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'abschliessen';
  static const String praeteritum = 'schloss ab';
  static const String perfekt = 'hat abgeschlossen';
  static const String arabicTranslation = 'فصل / إتمام الإبرام (التواصل الطبي)';
  static const String ipaTranscription = '[abˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2911_abschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung abschliessen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام الإبرام في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
