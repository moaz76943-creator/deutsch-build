// Sovereign Polyglot Core - Task 3936 (Financial Auditing)
class Task3936Engine {
  static const int taskId = 3936;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'mithalten';
  static const String praeteritum = 'hielt mit';
  static const String perfekt = 'hat mitgehalten';
  static const String arabicTranslation = 'مشاركة / تنسيق الالتزام (التدقيق المالي)';
  static const String ipaTranscription = '[mitˈˈhaltn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3936_mithalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung mithalten.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق الالتزام في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
