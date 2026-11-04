// Sovereign Polyglot Core - Task 4063 (Financial Auditing)
class Task4063Engine {
  static const int taskId = 4063;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'entrechnen';
  static const String praeteritum = 'entrechnete';
  static const String perfekt = 'hat entrechnet';
  static const String arabicTranslation = 'استخلاص / كشف التقدير (التدقيق المالي)';
  static const String ipaTranscription = '[entˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4063_entrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung entrechnen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التقدير في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
