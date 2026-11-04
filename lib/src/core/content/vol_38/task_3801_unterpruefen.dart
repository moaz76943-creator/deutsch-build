// Sovereign Polyglot Core - Task 3801 (Financial Auditing)
class Task3801Engine {
  static const int taskId = 3801;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'unterpruefen';
  static const String praeteritum = 'unterpruefte';
  static const String perfekt = 'hat unterprueft';
  static const String arabicTranslation = 'فحص / دعم التدقيق (التدقيق المالي)';
  static const String ipaTranscription = '[unterˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3801_unterpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung unterpruefen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التدقيق في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
