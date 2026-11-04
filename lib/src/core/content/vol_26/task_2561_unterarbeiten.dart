// Sovereign Polyglot Core - Task 2561 (Clinical Diagnostics)
class Task2561Engine {
  static const int taskId = 2561;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'unterarbeiten';
  static const String praeteritum = 'unterarbeitete';
  static const String perfekt = 'hat unterarbeitet';
  static const String arabicTranslation = 'فحص / دعم العمل (التواصل الطبي)';
  static const String ipaTranscription = '[unterˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2561_unterarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung unterarbeiten.';
  static const String exampleArabic = 'يجب علينا فحص / دعم العمل في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
