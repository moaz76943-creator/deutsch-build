// Sovereign Polyglot Core - Task 3409 (Contractual Compliance)
class Task3409Engine {
  static const int taskId = 3409;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'zusammenpruefen';
  static const String praeteritum = 'pruefte zusammen';
  static const String perfekt = 'hat zusammengeprueft';
  static const String arabicTranslation = 'تجميع / توحيد التدقيق (العقود والإدارة)';
  static const String ipaTranscription = '[zusammenˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3409_zusammenpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung zusammenpruefen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التدقيق أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
