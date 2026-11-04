// Sovereign Polyglot Core - Task 3574 (Contractual Compliance)
class Task3574Engine {
  static const int taskId = 3574;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'aussprechen';
  static const String praeteritum = 'sprach aus';
  static const String perfekt = 'hat ausgesprochen';
  static const String arabicTranslation = 'توسيع / استخراج التخاطب (العقود والإدارة)';
  static const String ipaTranscription = '[ausˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3574_aussprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung aussprechen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التخاطب أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
