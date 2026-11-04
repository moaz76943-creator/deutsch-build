// Sovereign Polyglot Core - Task 3815 (Financial Auditing)
class Task3815Engine {
  static const int taskId = 3815;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'einstellen';
  static const String praeteritum = 'stellte ein';
  static const String perfekt = 'hat eingestellt';
  static const String arabicTranslation = 'إدراج / دمج التنظيم (التدقيق المالي)';
  static const String ipaTranscription = '[einˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3815_einstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung einstellen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التنظيم في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
