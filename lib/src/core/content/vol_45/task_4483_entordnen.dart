// Sovereign Polyglot Core - Task 4483 (Supply Chain)
class Task4483Engine {
  static const int taskId = 4483;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'entordnen';
  static const String praeteritum = 'entordnete';
  static const String perfekt = 'hat entordnet';
  static const String arabicTranslation = 'استخلاص / كشف التصنيف (سلاسل الإمداد)';
  static const String ipaTranscription = '[entˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4483_entordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale entordnen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التصنيف في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
