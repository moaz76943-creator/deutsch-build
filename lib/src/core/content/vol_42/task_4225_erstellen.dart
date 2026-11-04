// Sovereign Polyglot Core - Task 4225 (Supply Chain)
class Task4225Engine {
  static const int taskId = 4225;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'erstellen';
  static const String praeteritum = 'erstellte';
  static const String perfekt = 'hat erstellt';
  static const String arabicTranslation = 'إنجاز / تحقيق التنظيم (سلاسل الإمداد)';
  static const String ipaTranscription = '[erˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4225_erstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale erstellen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التنظيم في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
