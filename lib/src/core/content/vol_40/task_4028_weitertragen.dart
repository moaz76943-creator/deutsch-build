// Sovereign Polyglot Core - Task 4028 (Financial Auditing)
class Task4028Engine {
  static const int taskId = 4028;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'weitertragen';
  static const String praeteritum = 'trug weiter';
  static const String perfekt = 'hat weitergetragen';
  static const String arabicTranslation = 'مواصلة / تمرير المسؤولية (التدقيق المالي)';
  static const String ipaTranscription = '[weiterˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4028_weitertragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung weitertragen.';
  static const String exampleArabic = 'يجب علينا مواصلة / تمرير المسؤولية في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
