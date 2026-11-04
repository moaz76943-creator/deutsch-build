// Sovereign Polyglot Core - Task 3355 (Contractual Compliance)
class Task3355Engine {
  static const int taskId = 3355;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'einarbeiten';
  static const String praeteritum = 'arbeitete ein';
  static const String perfekt = 'hat eingearbeitet';
  static const String arabicTranslation = 'إدراج / دمج العمل (العقود والإدارة)';
  static const String ipaTranscription = '[einˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3355_einarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung einarbeiten.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج العمل أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
