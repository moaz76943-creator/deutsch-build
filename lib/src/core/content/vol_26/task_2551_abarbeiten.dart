// Sovereign Polyglot Core - Task 2551 (Clinical Diagnostics)
class Task2551Engine {
  static const int taskId = 2551;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'abarbeiten';
  static const String praeteritum = 'arbeitete ab';
  static const String perfekt = 'hat abgearbeitet';
  static const String arabicTranslation = 'فصل / إتمام العمل (التواصل الطبي)';
  static const String ipaTranscription = '[abˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2551_abarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung abarbeiten.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام العمل في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
