// Sovereign Polyglot Core - Task 2726 (Clinical Diagnostics)
class Task2726Engine {
  static const int taskId = 2726;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'durchgeben';
  static const String praeteritum = 'gab durch';
  static const String perfekt = 'hat durchgegeben';
  static const String arabicTranslation = 'إتمام شامل التسليم (التواصل الطبي)';
  static const String ipaTranscription = '[durchˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2726_durchgeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung durchgeben.';
  static const String exampleArabic = 'يجب علينا إتمام شامل التسليم في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
