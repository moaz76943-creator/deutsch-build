// Sovereign Polyglot Core - Task 4029 (Financial Auditing)
class Task4029Engine {
  static const int taskId = 4029;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'zusammentragen';
  static const String praeteritum = 'trug zusammen';
  static const String perfekt = 'hat zusammengetragen';
  static const String arabicTranslation = 'تجميع / توحيد المسؤولية (التدقيق المالي)';
  static const String ipaTranscription = '[zusammenˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4029_zusammentragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung zusammentragen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد المسؤولية في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
