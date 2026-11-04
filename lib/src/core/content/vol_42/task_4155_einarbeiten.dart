// Sovereign Polyglot Core - Task 4155 (Supply Chain)
class Task4155Engine {
  static const int taskId = 4155;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'einarbeiten';
  static const String praeteritum = 'arbeitete ein';
  static const String perfekt = 'hat eingearbeitet';
  static const String arabicTranslation = 'إدراج / دمج العمل (سلاسل الإمداد)';
  static const String ipaTranscription = '[einˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4155_einarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale einarbeiten.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج العمل في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
