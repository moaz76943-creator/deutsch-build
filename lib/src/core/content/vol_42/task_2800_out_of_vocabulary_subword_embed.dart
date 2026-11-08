// Sovereign Vector Database Architecture Unit - Task 2800
class Task2800Engine {
  static const int taskId = 2800;
  static const String identifier = 'out_of_vocabulary_subword_embed';
  static const String titleAr = 'معالجة الكلمات النادرة بتفكيكها إلى مقاطع فرعية بالمتجهات';
  static const String topicDe = 'Unterwort-Repräsentationen';
  static const String cefrLevel = 'B2';
  static const String vectorPhraseDe = 'BPE-Tokenisierung generiert bedeutungstragende Vektoren für unbekannte Neologismen.';
  static const String vectorPhraseAr = 'تجزئة BPE تولد متجهات ذات دلالة للكلمات والمصطلحات الجديدة.';
  static const String audioAssetPath = 'assets/audio/vector_db/task_2800_out_of_vocabulary_subword_embed.ogg';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'title_ar': titleAr,
    'topic_de': topicDe, 'cefr': cefrLevel, 'phrase_de': vectorPhraseDe,
    'phrase_ar': vectorPhraseAr, 'audio': audioAssetPath,
  };

  static bool evaluateVector(String similarity) => similarity.trim().isNotEmpty;
}
