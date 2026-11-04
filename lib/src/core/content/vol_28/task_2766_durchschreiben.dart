// Sovereign Polyglot Core - Task 2766 (Clinical Diagnostics)
class Task2766Engine {
  static const int taskId = 2766;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'durchschreiben';
  static const String praeteritum = 'schrieb durch';
  static const String perfekt = 'hat durchgeschrieben';
  static const String arabicTranslation = 'إتمام شامل التدوين (التواصل الطبي)';
  static const String ipaTranscription = '[durchˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2766_durchschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung durchschreiben.';
  static const String exampleArabic = 'يجب علينا إتمام شامل التدوين في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
