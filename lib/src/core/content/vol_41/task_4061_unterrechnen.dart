// Sovereign Polyglot Core - Task 4061 (Financial Auditing)
class Task4061Engine {
  static const int taskId = 4061;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'unterrechnen';
  static const String praeteritum = 'unterrechnete';
  static const String perfekt = 'hat unterrechnet';
  static const String arabicTranslation = 'فحص / دعم التقدير (التدقيق المالي)';
  static const String ipaTranscription = '[unterˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4061_unterrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung unterrechnen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التقدير في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
