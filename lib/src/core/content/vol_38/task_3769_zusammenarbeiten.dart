// Sovereign Polyglot Core - Task 3769 (Financial Auditing)
class Task3769Engine {
  static const int taskId = 3769;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'zusammenarbeiten';
  static const String praeteritum = 'arbeitete zusammen';
  static const String perfekt = 'hat zusammengearbeitet';
  static const String arabicTranslation = 'تجميع / توحيد العمل (التدقيق المالي)';
  static const String ipaTranscription = '[zusammenˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3769_zusammenarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung zusammenarbeiten.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد العمل في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
