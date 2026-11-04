// Sovereign Polyglot Core - Task 2651 (Clinical Diagnostics)
class Task2651Engine {
  static const int taskId = 2651;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'abfuehren';
  static const String praeteritum = 'fuehrte ab';
  static const String perfekt = 'hat abgefuehrt';
  static const String arabicTranslation = 'فصل / إتمام الإدارة (التواصل الطبي)';
  static const String ipaTranscription = '[abˈˈfyːʁən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2651_abfuehren.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung abfuehren.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام الإدارة في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
