// Sovereign Polyglot Core - Task 4083 (Financial Auditing)
class Task4083Engine {
  static const int taskId = 4083;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'entordnen';
  static const String praeteritum = 'entordnete';
  static const String perfekt = 'hat entordnet';
  static const String arabicTranslation = 'استخلاص / كشف التصنيف (التدقيق المالي)';
  static const String ipaTranscription = '[entˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4083_entordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung entordnen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التصنيف في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
