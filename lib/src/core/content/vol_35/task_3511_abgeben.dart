// Sovereign Polyglot Core - Task 3511 (Contractual Compliance)
class Task3511Engine {
  static const int taskId = 3511;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'abgeben';
  static const String praeteritum = 'gab ab';
  static const String perfekt = 'hat abgegeben';
  static const String arabicTranslation = 'فصل / إتمام التسليم (العقود والإدارة)';
  static const String ipaTranscription = '[abˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3511_abgeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung abgeben.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التسليم أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
