// Sovereign Polyglot Core - Task 4381 (Supply Chain)
class Task4381Engine {
  static const int taskId = 4381;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'untersprechen';
  static const String praeteritum = 'untersprach';
  static const String perfekt = 'hat untersprochen';
  static const String arabicTranslation = 'فحص / دعم التخاطب (سلاسل الإمداد)';
  static const String ipaTranscription = '[unterˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4381_untersprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale untersprechen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التخاطب في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
