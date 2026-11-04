// Sovereign Polyglot Core - Task 3980 (Financial Auditing)
class Task3980Engine {
  static const int taskId = 3980;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'uebersprechen';
  static const String praeteritum = 'uebersprach';
  static const String perfekt = 'hat uebersprochen';
  static const String arabicTranslation = 'مراجعة / نقل التخاطب (التدقيق المالي)';
  static const String ipaTranscription = '[ueberˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3980_uebersprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung uebersprechen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التخاطب في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
