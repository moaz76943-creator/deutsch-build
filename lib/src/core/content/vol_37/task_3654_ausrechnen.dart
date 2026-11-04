// Sovereign Polyglot Core - Task 3654 (Contractual Compliance)
class Task3654Engine {
  static const int taskId = 3654;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'ausrechnen';
  static const String praeteritum = 'rechnete aus';
  static const String perfekt = 'hat ausgerechnet';
  static const String arabicTranslation = 'توسيع / استخراج التقدير (العقود والإدارة)';
  static const String ipaTranscription = '[ausˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3654_ausrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung ausrechnen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التقدير أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
