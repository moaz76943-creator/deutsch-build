// Sovereign Polyglot Core - Task 4221 (Supply Chain)
class Task4221Engine {
  static const int taskId = 4221;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'unterstellen';
  static const String praeteritum = 'unterstellte';
  static const String perfekt = 'hat unterstellt';
  static const String arabicTranslation = 'فحص / دعم التنظيم (سلاسل الإمداد)';
  static const String ipaTranscription = '[unterˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4221_unterstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale unterstellen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التنظيم في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
