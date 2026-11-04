// Sovereign Polyglot Core - Task 3635 (Contractual Compliance)
class Task3635Engine {
  static const int taskId = 3635;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'einweisen';
  static const String praeteritum = 'wies ein';
  static const String perfekt = 'hat eingewiesen';
  static const String arabicTranslation = 'إدراج / دمج التوجيه (العقود والإدارة)';
  static const String ipaTranscription = '[einˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3635_einweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung einweisen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التوجيه أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
