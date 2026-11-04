// Sovereign Polyglot Core - Task 4428 (Supply Chain)
class Task4428Engine {
  static const int taskId = 4428;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'weitertragen';
  static const String praeteritum = 'trug weiter';
  static const String perfekt = 'hat weitergetragen';
  static const String arabicTranslation = 'مواصلة / تمرير المسؤولية (سلاسل الإمداد)';
  static const String ipaTranscription = '[weiterˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4428_weitertragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale weitertragen.';
  static const String exampleArabic = 'يجب علينا مواصلة / تمرير المسؤولية في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
