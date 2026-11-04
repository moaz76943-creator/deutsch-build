// Sovereign Polyglot Core - Task 3367 (Contractual Compliance)
class Task3367Engine {
  static const int taskId = 3367;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'umarbeiten';
  static const String praeteritum = 'arbeitete um';
  static const String perfekt = 'hat umgearbeitet';
  static const String arabicTranslation = 'إعادة هيكلة العمل (العقود والإدارة)';
  static const String ipaTranscription = '[umˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3367_umarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung umarbeiten.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة العمل أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
