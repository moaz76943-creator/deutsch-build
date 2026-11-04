// Sovereign Polyglot Core - Task 3768 (Financial Auditing)
class Task3768Engine {
  static const int taskId = 3768;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'weiterarbeiten';
  static const String praeteritum = 'arbeitete weiter';
  static const String perfekt = 'hat weitergearbeitet';
  static const String arabicTranslation = 'مواصلة / تمرير العمل (التدقيق المالي)';
  static const String ipaTranscription = '[weiterˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3768_weiterarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung weiterarbeiten.';
  static const String exampleArabic = 'يجب علينا مواصلة / تمرير العمل في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
