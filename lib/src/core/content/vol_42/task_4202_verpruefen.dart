// Sovereign Polyglot Core - Task 4202 (Supply Chain)
class Task4202Engine {
  static const int taskId = 4202;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'verpruefen';
  static const String praeteritum = 'verpruefte';
  static const String perfekt = 'hat verprueft';
  static const String arabicTranslation = 'توثيق / معالجة التدقيق (سلاسل الإمداد)';
  static const String ipaTranscription = '[verˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4202_verpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale verpruefen.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة التدقيق في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
