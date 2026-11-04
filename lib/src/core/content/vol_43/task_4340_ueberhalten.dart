// Sovereign Polyglot Core - Task 4340 (Supply Chain)
class Task4340Engine {
  static const int taskId = 4340;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'ueberhalten';
  static const String praeteritum = 'ueberhielt';
  static const String perfekt = 'hat ueberhalten';
  static const String arabicTranslation = 'مراجعة / نقل الالتزام (سلاسل الإمداد)';
  static const String ipaTranscription = '[ueberˈˈhaltn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4340_ueberhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale ueberhalten.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل الالتزام في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
