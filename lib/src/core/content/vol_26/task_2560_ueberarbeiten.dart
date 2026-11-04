// Sovereign Polyglot Core - Task 2560 (Clinical Diagnostics)
class Task2560Engine {
  static const int taskId = 2560;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'ueberarbeiten';
  static const String praeteritum = 'ueberarbeitete';
  static const String perfekt = 'hat ueberarbeitet';
  static const String arabicTranslation = 'مراجعة / نقل العمل (التواصل الطبي)';
  static const String ipaTranscription = '[ueberˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2560_ueberarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung ueberarbeiten.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل العمل في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
