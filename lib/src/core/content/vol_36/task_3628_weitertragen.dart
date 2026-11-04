// Sovereign Polyglot Core - Task 3628 (Contractual Compliance)
class Task3628Engine {
  static const int taskId = 3628;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'weitertragen';
  static const String praeteritum = 'trug weiter';
  static const String perfekt = 'hat weitergetragen';
  static const String arabicTranslation = 'مواصلة / تمرير المسؤولية (العقود والإدارة)';
  static const String ipaTranscription = '[weiterˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3628_weitertragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung weitertragen.';
  static const String exampleArabic = 'يجب علينا مواصلة / تمرير المسؤولية أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
