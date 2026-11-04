// Sovereign Polyglot Core - Task 2941 (Clinical Diagnostics)
class Task2941Engine {
  static const int taskId = 2941;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'unterbauen';
  static const String praeteritum = 'unterbaute';
  static const String perfekt = 'hat unterbaut';
  static const String arabicTranslation = 'فحص / دعم التطوير (التواصل الطبي)';
  static const String ipaTranscription = '[unterˈˈbaʊ̯ən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2941_unterbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung unterbauen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التطوير في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
