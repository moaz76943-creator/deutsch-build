// Sovereign Polyglot Core - Task 3796 (Financial Auditing)
class Task3796Engine {
  static const int taskId = 3796;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'mitpruefen';
  static const String praeteritum = 'pruefte mit';
  static const String perfekt = 'hat mitgeprueft';
  static const String arabicTranslation = 'مشاركة / تنسيق التدقيق (التدقيق المالي)';
  static const String ipaTranscription = '[mitˈˈpʁyːfn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3796_mitpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung mitpruefen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التدقيق في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
