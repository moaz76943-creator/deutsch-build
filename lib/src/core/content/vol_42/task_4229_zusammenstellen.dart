// Sovereign Polyglot Core - Task 4229 (Supply Chain)
class Task4229Engine {
  static const int taskId = 4229;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'zusammenstellen';
  static const String praeteritum = 'stellte zusammen';
  static const String perfekt = 'hat zusammengestellt';
  static const String arabicTranslation = 'تجميع / توحيد التنظيم (سلاسل الإمداد)';
  static const String ipaTranscription = '[zusammenˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4229_zusammenstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale zusammenstellen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التنظيم في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
