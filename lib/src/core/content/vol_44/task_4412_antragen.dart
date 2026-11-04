// Sovereign Polyglot Core - Task 4412 (Supply Chain)
class Task4412Engine {
  static const int taskId = 4412;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'antragen';
  static const String praeteritum = 'trug an';
  static const String perfekt = 'hat angetragen';
  static const String arabicTranslation = 'بدء / توجيه المسؤولية (سلاسل الإمداد)';
  static const String ipaTranscription = '[anˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4412_antragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale antragen.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه المسؤولية في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
