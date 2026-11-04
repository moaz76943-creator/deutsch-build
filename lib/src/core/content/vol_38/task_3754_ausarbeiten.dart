// Sovereign Polyglot Core - Task 3754 (Financial Auditing)
class Task3754Engine {
  static const int taskId = 3754;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'ausarbeiten';
  static const String praeteritum = 'arbeitete aus';
  static const String perfekt = 'hat ausgearbeitet';
  static const String arabicTranslation = 'توسيع / استخراج العمل (التدقيق المالي)';
  static const String ipaTranscription = '[ausˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3754_ausarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung ausarbeiten.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج العمل في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
