// Sovereign Polyglot Core - Task 3653 (Contractual Compliance)
class Task3653Engine {
  static const int taskId = 3653;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'aufrechnen';
  static const String praeteritum = 'rechnete auf';
  static const String perfekt = 'hat aufgerechnet';
  static const String arabicTranslation = 'رفع / فتح التقدير (العقود والإدارة)';
  static const String ipaTranscription = '[aufˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3653_aufrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung aufrechnen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التقدير أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
