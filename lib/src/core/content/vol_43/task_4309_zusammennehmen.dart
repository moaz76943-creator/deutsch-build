// Sovereign Polyglot Core - Task 4309 (Supply Chain)
class Task4309Engine {
  static const int taskId = 4309;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'zusammennehmen';
  static const String praeteritum = 'nahm zusammen';
  static const String perfekt = 'hat zusammengenommen';
  static const String arabicTranslation = 'تجميع / توحيد الاستلام (سلاسل الإمداد)';
  static const String ipaTranscription = '[zusammenˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4309_zusammennehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale zusammennehmen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد الاستلام في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
