// Sovereign Polyglot Core - Task 2564 (Clinical Diagnostics)
class Task2564Engine {
  static const int taskId = 2564;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'bearbeiten';
  static const String praeteritum = 'bearbeitete';
  static const String perfekt = 'hat bearbeitet';
  static const String arabicTranslation = 'تأكيد / تزويد العمل (التواصل الطبي)';
  static const String ipaTranscription = '[beˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2564_bearbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung bearbeiten.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد العمل في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
