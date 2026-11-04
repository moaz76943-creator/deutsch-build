// Sovereign Polyglot Core - Task 3972 (Financial Auditing)
class Task3972Engine {
  static const int taskId = 3972;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'ansprechen';
  static const String praeteritum = 'sprach an';
  static const String perfekt = 'hat angesprochen';
  static const String arabicTranslation = 'بدء / توجيه التخاطب (التدقيق المالي)';
  static const String ipaTranscription = '[anˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3972_ansprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung ansprechen.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه التخاطب في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
