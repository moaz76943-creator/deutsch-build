// Sovereign Polyglot Core - Task 2931 (Clinical Diagnostics)
class Task2931Engine {
  static const int taskId = 2931;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'abbauen';
  static const String praeteritum = 'baute ab';
  static const String perfekt = 'hat abgebaut';
  static const String arabicTranslation = 'فصل / إتمام التطوير (التواصل الطبي)';
  static const String ipaTranscription = '[abˈˈbaʊ̯ən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2931_abbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung abbauen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التطوير في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
