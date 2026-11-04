// Sovereign Polyglot Core - Task 3360 (Contractual Compliance)
class Task3360Engine {
  static const int taskId = 3360;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'ueberarbeiten';
  static const String praeteritum = 'ueberarbeitete';
  static const String perfekt = 'hat ueberarbeitet';
  static const String arabicTranslation = 'مراجعة / نقل العمل (العقود والإدارة)';
  static const String ipaTranscription = '[ueberˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3360_ueberarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung ueberarbeiten.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل العمل أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
