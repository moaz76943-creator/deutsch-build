// Sovereign Polyglot Core - Task 3755 (Financial Auditing)
class Task3755Engine {
  static const int taskId = 3755;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'einarbeiten';
  static const String praeteritum = 'arbeitete ein';
  static const String perfekt = 'hat eingearbeitet';
  static const String arabicTranslation = 'إدراج / دمج العمل (التدقيق المالي)';
  static const String ipaTranscription = '[einˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3755_einarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung einarbeiten.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج العمل في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
