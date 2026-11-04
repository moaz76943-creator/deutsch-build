// Sovereign Polyglot Core - Task 2556 (Clinical Diagnostics)
class Task2556Engine {
  static const int taskId = 2556;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'mitarbeiten';
  static const String praeteritum = 'arbeitete mit';
  static const String perfekt = 'hat mitgearbeitet';
  static const String arabicTranslation = 'مشاركة / تنسيق العمل (التواصل الطبي)';
  static const String ipaTranscription = '[mitˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2556_mitarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung mitarbeiten.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق العمل في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
