// Sovereign Polyglot Core - Task 2826 (Clinical Diagnostics)
class Task2826Engine {
  static const int taskId = 2826;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'durchtragen';
  static const String praeteritum = 'trug durch';
  static const String perfekt = 'hat durchgetragen';
  static const String arabicTranslation = 'إتمام شامل المسؤولية (التواصل الطبي)';
  static const String ipaTranscription = '[durchˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2826_durchtragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung durchtragen.';
  static const String exampleArabic = 'يجب علينا إتمام شامل المسؤولية في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
