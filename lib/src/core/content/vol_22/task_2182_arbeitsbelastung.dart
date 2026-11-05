// Sovereign Nominal Core - Task 2182
class Task2182Engine {
  static const int taskId = 2182;
  static const String identifier = 'arbeitsbelastung';
  static const String germanNoun = 'die Arbeitsbelastung';
  static const String arabicTranslation = 'عبء العمل والضغط الوظيفي';
  static const String ipaTranscription = '[ˈaʁbaɪ̯tsbəˌlastʊŋ]';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/nouns/task_2182_arbeitsbelastung.ogg';
  static const String exampleGerman = 'Die Arbeitsbelastung ist gestiegen.';
  static const String exampleArabic = 'ارتفع عبء العمل مؤخراً.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'noun': germanNoun,
    'arabic': arabicTranslation, 'ipa': ipaTranscription, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => germanNoun.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
