// Sovereign Adverbial Modifier Core - Task 2250
class Task2250Engine {
  static const int taskId = 2250;
  static const String identifier = 'ueberdies';
  static const String adverbGerman = 'überdies';
  static const String arabicMeaning = 'علاوة على ذلك / فضلاً عن ذلك';
  static const String ipaTranscription = '[yːbɐˈdiːs]';
  static const String cefrLevel = 'C1';
  static const String grammaticalCategory = 'Kopulativadverb';
  static const String audioAssetPath = 'assets/audio/adv/task_2250_ueberdies.ogg';
  static const String exampleGerman = 'Der Entwurf ist ueberdies sehr robust.';
  static const String exampleArabic = 'التصميم علاوة على ذلك فائق المتانة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'adverb': adverbGerman,
    'arabic': arabicMeaning, 'ipa': ipaTranscription, 'cefr': cefrLevel,
    'category': grammaticalCategory, 'audio': audioAssetPath,
    'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => adverbGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
