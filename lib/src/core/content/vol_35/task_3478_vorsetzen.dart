// Sovereign Polyglot Core - Task 3478 (Contractual Compliance)
class Task3478Engine {
  static const int taskId = 3478;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'vorsetzen';
  static const String praeteritum = 'setzte vor';
  static const String perfekt = 'hat vorgesetzt';
  static const String arabicTranslation = 'تقديم / تحضير التنفيذ (العقود والإدارة)';
  static const String ipaTranscription = '[vorˈˈzɛtsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3478_vorsetzen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung vorsetzen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التنفيذ أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
