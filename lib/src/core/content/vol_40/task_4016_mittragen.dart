// Sovereign Polyglot Core - Task 4016 (Financial Auditing)
class Task4016Engine {
  static const int taskId = 4016;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'mittragen';
  static const String praeteritum = 'trug mit';
  static const String perfekt = 'hat mitgetragen';
  static const String arabicTranslation = 'مشاركة / تنسيق المسؤولية (التدقيق المالي)';
  static const String ipaTranscription = '[mitˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4016_mittragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung mittragen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق المسؤولية في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
