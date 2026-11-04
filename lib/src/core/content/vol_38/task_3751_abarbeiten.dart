// Sovereign Polyglot Core - Task 3751 (Financial Auditing)
class Task3751Engine {
  static const int taskId = 3751;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'abarbeiten';
  static const String praeteritum = 'arbeitete ab';
  static const String perfekt = 'hat abgearbeitet';
  static const String arabicTranslation = 'فصل / إتمام العمل (التدقيق المالي)';
  static const String ipaTranscription = '[abˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3751_abarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung abarbeiten.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام العمل في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
