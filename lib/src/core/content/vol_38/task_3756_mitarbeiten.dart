// Sovereign Polyglot Core - Task 3756 (Financial Auditing)
class Task3756Engine {
  static const int taskId = 3756;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'mitarbeiten';
  static const String praeteritum = 'arbeitete mit';
  static const String perfekt = 'hat mitgearbeitet';
  static const String arabicTranslation = 'مشاركة / تنسيق العمل (التدقيق المالي)';
  static const String ipaTranscription = '[mitˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3756_mitarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung mitarbeiten.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق العمل في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
