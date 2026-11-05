// Sovereign Functional Verb Core - Task 2212
class Task2212Engine {
  static const int taskId = 2212;
  static const String identifier = 'zur_verfuegung_stellen';
  static const String phraseGerman = 'zur Verfuegung stellen';
  static const String arabicMeaning = 'يضع تحت التصرف / يتيح';
  static const String ipaTranscription = '[tsuːɐ̯ fɛɐ̯ˈfyːɡʊŋ ˈʃtɛlən]';
  static const String cefrLevel = 'B2';
  static const String simpleVerbEquivalent = 'bereitstellen';
  static const String audioAssetPath = 'assets/audio/fvg/task_2212_zur_verfuegung_stellen.ogg';
  static const String exampleGerman = 'Das Institut stellt neue Geraete zur Verfuegung.';
  static const String exampleArabic = 'يضع المعهد أجهزة جديدة تحت التصرف.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': phraseGerman,
    'arabic': arabicMeaning, 'ipa': ipaTranscription, 'cefr': cefrLevel,
    'equivalent': simpleVerbEquivalent, 'audio': audioAssetPath,
    'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => phraseGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
