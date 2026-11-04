// Sovereign Polyglot Core - Task 3369 (Contractual Compliance)
class Task3369Engine {
  static const int taskId = 3369;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'zusammenarbeiten';
  static const String praeteritum = 'arbeitete zusammen';
  static const String perfekt = 'hat zusammengearbeitet';
  static const String arabicTranslation = 'تجميع / توحيد العمل (العقود والإدارة)';
  static const String ipaTranscription = '[zusammenˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3369_zusammenarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung zusammenarbeiten.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد العمل أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
