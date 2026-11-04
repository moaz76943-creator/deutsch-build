// Sovereign Polyglot Core - Task 3667 (Contractual Compliance)
class Task3667Engine {
  static const int taskId = 3667;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'umrechnen';
  static const String praeteritum = 'rechnete um';
  static const String perfekt = 'hat umgerechnet';
  static const String arabicTranslation = 'إعادة هيكلة التقدير (العقود والإدارة)';
  static const String ipaTranscription = '[umˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3667_umrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung umrechnen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التقدير أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
