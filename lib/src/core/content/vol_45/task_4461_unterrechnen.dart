// Sovereign Polyglot Core - Task 4461 (Supply Chain)
class Task4461Engine {
  static const int taskId = 4461;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'unterrechnen';
  static const String praeteritum = 'unterrechnete';
  static const String perfekt = 'hat unterrechnet';
  static const String arabicTranslation = 'فحص / دعم التقدير (سلاسل الإمداد)';
  static const String ipaTranscription = '[unterˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4461_unterrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale unterrechnen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التقدير في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
