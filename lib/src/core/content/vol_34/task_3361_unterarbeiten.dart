// Sovereign Polyglot Core - Task 3361 (Contractual Compliance)
class Task3361Engine {
  static const int taskId = 3361;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'unterarbeiten';
  static const String praeteritum = 'unterarbeitete';
  static const String perfekt = 'hat unterarbeitet';
  static const String arabicTranslation = 'فحص / دعم العمل (العقود والإدارة)';
  static const String ipaTranscription = '[unterˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3361_unterarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung unterarbeiten.';
  static const String exampleArabic = 'يجب علينا فحص / دعم العمل أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
