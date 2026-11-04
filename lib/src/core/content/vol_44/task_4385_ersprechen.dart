// Sovereign Polyglot Core - Task 4385 (Supply Chain)
class Task4385Engine {
  static const int taskId = 4385;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'ersprechen';
  static const String praeteritum = 'ersprach';
  static const String perfekt = 'hat ersprochen';
  static const String arabicTranslation = 'إنجاز / تحقيق التخاطب (سلاسل الإمداد)';
  static const String ipaTranscription = '[erˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4385_ersprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale ersprechen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التخاطب في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
