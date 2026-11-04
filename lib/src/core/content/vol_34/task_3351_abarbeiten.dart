// Sovereign Polyglot Core - Task 3351 (Contractual Compliance)
class Task3351Engine {
  static const int taskId = 3351;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'abarbeiten';
  static const String praeteritum = 'arbeitete ab';
  static const String perfekt = 'hat abgearbeitet';
  static const String arabicTranslation = 'فصل / إتمام العمل (العقود والإدارة)';
  static const String ipaTranscription = '[abˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3351_abarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung abarbeiten.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام العمل أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
