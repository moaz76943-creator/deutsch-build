// Sovereign Polyglot Core - Task 4467 (Supply Chain)
class Task4467Engine {
  static const int taskId = 4467;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'umrechnen';
  static const String praeteritum = 'rechnete um';
  static const String perfekt = 'hat umgerechnet';
  static const String arabicTranslation = 'إعادة هيكلة التقدير (سلاسل الإمداد)';
  static const String ipaTranscription = '[umˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4467_umrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale umrechnen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التقدير في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
