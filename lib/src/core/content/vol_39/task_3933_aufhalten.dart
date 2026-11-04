// Sovereign Polyglot Core - Task 3933 (Financial Auditing)
class Task3933Engine {
  static const int taskId = 3933;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'aufhalten';
  static const String praeteritum = 'hielt auf';
  static const String perfekt = 'hat aufgehalten';
  static const String arabicTranslation = 'رفع / فتح الالتزام (التدقيق المالي)';
  static const String ipaTranscription = '[aufˈˈhaltn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3933_aufhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung aufhalten.';
  static const String exampleArabic = 'يجب علينا رفع / فتح الالتزام في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
