// Sovereign Polyglot Core - Task 4313 (Supply Chain)
class Task4313Engine {
  static const int taskId = 4313;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'aufgeben';
  static const String praeteritum = 'gab auf';
  static const String perfekt = 'hat aufgegeben';
  static const String arabicTranslation = 'رفع / فتح التسليم (سلاسل الإمداد)';
  static const String ipaTranscription = '[aufˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4313_aufgeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale aufgeben.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التسليم في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
