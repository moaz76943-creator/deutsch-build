// Sovereign Diplomatic Konjunktiv Core - Task 2275
class Task2275Engine {
  static const int taskId = 2275;
  static const String identifier = 'gewoenne_eindruck';
  static const String phraseGerman = 'man gewönne den Eindruck';
  static const String arabicMeaning = 'يتشكل لدى المرء انطباع أولي بأن';
  static const String ipaTranscription = '[man ɡəˈvœnə deːn ˈʔaɪ̯ndʁʊk]';
  static const String cefrLevel = 'C1';
  static const String pragmaticFunction = 'Distanzierte Beobachtung';
  static const String audioAssetPath = 'assets/audio/konj2/task_2275_gewoenne_eindruck.ogg';
  static const String exampleGerman = 'Man gewönne den Eindruck voller Stabilität.';
  static const String exampleArabic = 'يتشكل لدى المرء انطباع بالاستقرار التام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': phraseGerman,
    'arabic': arabicMeaning, 'ipa': ipaTranscription, 'cefr': cefrLevel,
    'function': pragmaticFunction, 'audio': audioAssetPath,
    'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => phraseGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
