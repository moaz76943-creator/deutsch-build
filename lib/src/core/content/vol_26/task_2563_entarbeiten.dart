// Sovereign Polyglot Core - Task 2563 (Clinical Diagnostics)
class Task2563Engine {
  static const int taskId = 2563;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'entarbeiten';
  static const String praeteritum = 'entarbeitete';
  static const String perfekt = 'hat entarbeitet';
  static const String arabicTranslation = 'استخلاص / كشف العمل (التواصل الطبي)';
  static const String ipaTranscription = '[entˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2563_entarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung entarbeiten.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف العمل في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
