// Sovereign Polyglot Core - Task 3669 (Contractual Compliance)
class Task3669Engine {
  static const int taskId = 3669;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'zusammenrechnen';
  static const String praeteritum = 'rechnete zusammen';
  static const String perfekt = 'hat zusammengerechnet';
  static const String arabicTranslation = 'تجميع / توحيد التقدير (العقود والإدارة)';
  static const String ipaTranscription = '[zusammenˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3669_zusammenrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung zusammenrechnen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التقدير أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
