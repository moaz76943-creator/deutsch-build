// Sovereign Polyglot Core - Task 3783 (Financial Auditing)
class Task3783Engine {
  static const int taskId = 3783;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'entplanen';
  static const String praeteritum = 'entplante';
  static const String perfekt = 'hat entplant';
  static const String arabicTranslation = 'استخلاص / كشف التخطيط (التدقيق المالي)';
  static const String ipaTranscription = '[entˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3783_entplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung entplanen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التخطيط في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
