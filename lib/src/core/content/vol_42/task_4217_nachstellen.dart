// Sovereign Polyglot Core - Task 4217 (Supply Chain)
class Task4217Engine {
  static const int taskId = 4217;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'nachstellen';
  static const String praeteritum = 'stellte nach';
  static const String perfekt = 'hat nachgestellt';
  static const String arabicTranslation = 'تدقيق / متابعة التنظيم (سلاسل الإمداد)';
  static const String ipaTranscription = '[nachˈˈʃtɛlən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4217_nachstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale nachstellen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التنظيم في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
