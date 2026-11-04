// Sovereign Polyglot Core - Task 3413 (Contractual Compliance)
class Task3413Engine {
  static const int taskId = 3413;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'aufstellen';
  static const String praeteritum = 'stellte auf';
  static const String perfekt = 'hat aufgestellt';
  static const String arabicTranslation = 'رفع / فتح التنظيم (العقود والإدارة)';
  static const String ipaTranscription = '[aufˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3413_aufstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung aufstellen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التنظيم أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
