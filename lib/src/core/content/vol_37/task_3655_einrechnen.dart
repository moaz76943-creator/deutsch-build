// Sovereign Polyglot Core - Task 3655 (Contractual Compliance)
class Task3655Engine {
  static const int taskId = 3655;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'einrechnen';
  static const String praeteritum = 'rechnete ein';
  static const String perfekt = 'hat eingerechnet';
  static const String arabicTranslation = 'إدراج / دمج التقدير (العقود والإدارة)';
  static const String ipaTranscription = '[einˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3655_einrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung einrechnen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التقدير أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
