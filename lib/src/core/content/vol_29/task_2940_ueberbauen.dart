// Sovereign Polyglot Core - Task 2940 (Clinical Diagnostics)
class Task2940Engine {
  static const int taskId = 2940;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'ueberbauen';
  static const String praeteritum = 'ueberbaute';
  static const String perfekt = 'hat ueberbaut';
  static const String arabicTranslation = 'مراجعة / نقل التطوير (التواصل الطبي)';
  static const String ipaTranscription = '[ueberˈˈbaʊ̯ən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2940_ueberbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung ueberbauen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التطوير في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
