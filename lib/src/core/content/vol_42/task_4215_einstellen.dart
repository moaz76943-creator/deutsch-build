// Sovereign Polyglot Core - Task 4215 (Supply Chain)
class Task4215Engine {
  static const int taskId = 4215;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'einstellen';
  static const String praeteritum = 'stellte ein';
  static const String perfekt = 'hat eingestellt';
  static const String arabicTranslation = 'إدراج / دمج التنظيم (سلاسل الإمداد)';
  static const String ipaTranscription = '[einˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4215_einstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale einstellen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التنظيم في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
