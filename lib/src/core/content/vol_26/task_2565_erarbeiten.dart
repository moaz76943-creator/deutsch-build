// Sovereign Polyglot Core - Task 2565 (Clinical Diagnostics)
class Task2565Engine {
  static const int taskId = 2565;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'erarbeiten';
  static const String praeteritum = 'erarbeitete';
  static const String perfekt = 'hat erarbeitet';
  static const String arabicTranslation = 'إنجاز / تحقيق العمل (التواصل الطبي)';
  static const String ipaTranscription = '[erˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2565_erarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung erarbeiten.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق العمل في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
