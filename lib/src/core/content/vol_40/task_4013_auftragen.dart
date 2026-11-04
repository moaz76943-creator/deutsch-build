// Sovereign Polyglot Core - Task 4013 (Financial Auditing)
class Task4013Engine {
  static const int taskId = 4013;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'auftragen';
  static const String praeteritum = 'trug auf';
  static const String perfekt = 'hat aufgetragen';
  static const String arabicTranslation = 'رفع / فتح المسؤولية (التدقيق المالي)';
  static const String ipaTranscription = '[aufˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4013_auftragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung auftragen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح المسؤولية في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
