// Sovereign Polyglot Core - Task 2557 (Clinical Diagnostics)
class Task2557Engine {
  static const int taskId = 2557;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'nacharbeiten';
  static const String praeteritum = 'arbeitete nach';
  static const String perfekt = 'hat nachgearbeitet';
  static const String arabicTranslation = 'تدقيق / متابعة العمل (التواصل الطبي)';
  static const String ipaTranscription = '[nachˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2557_nacharbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung nacharbeiten.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة العمل في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
