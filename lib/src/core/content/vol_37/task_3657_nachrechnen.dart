// Sovereign Polyglot Core - Task 3657 (Contractual Compliance)
class Task3657Engine {
  static const int taskId = 3657;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'nachrechnen';
  static const String praeteritum = 'rechnete nach';
  static const String perfekt = 'hat nachgerechnet';
  static const String arabicTranslation = 'تدقيق / متابعة التقدير (العقود والإدارة)';
  static const String ipaTranscription = '[nachˈˈʁɛçnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3657_nachrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung nachrechnen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التقدير أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
