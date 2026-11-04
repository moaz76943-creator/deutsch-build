// Sovereign Polyglot Core - Task 3357 (Contractual Compliance)
class Task3357Engine {
  static const int taskId = 3357;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'nacharbeiten';
  static const String praeteritum = 'arbeitete nach';
  static const String perfekt = 'hat nachgearbeitet';
  static const String arabicTranslation = 'تدقيق / متابعة العمل (العقود والإدارة)';
  static const String ipaTranscription = '[nachˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3357_nacharbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung nacharbeiten.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة العمل أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
