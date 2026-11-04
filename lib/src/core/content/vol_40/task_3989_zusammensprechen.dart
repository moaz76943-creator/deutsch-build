// Sovereign Polyglot Core - Task 3989 (Financial Auditing)
class Task3989Engine {
  static const int taskId = 3989;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'zusammensprechen';
  static const String praeteritum = 'sprach zusammen';
  static const String perfekt = 'hat zusammengesprochen';
  static const String arabicTranslation = 'تجميع / توحيد التخاطب (التدقيق المالي)';
  static const String ipaTranscription = '[zusammenˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3989_zusammensprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung zusammensprechen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التخاطب في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
