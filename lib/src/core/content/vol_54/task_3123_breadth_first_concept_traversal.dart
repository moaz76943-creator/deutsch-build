// Sovereign Knowledge Graph Architecture Unit - Task 3123
class Task3123Engine {
  static const int taskId = 3123;
  static const String identifier = 'breadth_first_concept_traversal';
  static const String titleAr = 'استكشاف شجرة المفاهيم اللغوية بخوارزمية البحث في العرض BFS';
  static const String topicDe = 'Graph-Traversierung';
  static const String cefrLevel = 'B2';
  static const String graphPhraseDe = 'Breitensuche priorisiert eng verwandte Wortfamilien vor Spezialfällen.';
  static const String graphPhraseAr = 'البحث في العرض يقدم عائلات الكلمات المترابطة أولاً.';
  static const String audioAssetPath = 'assets/audio/graph/task_3123_breadth_first_concept_traversal.ogg';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'title_ar': titleAr,
    'topic_de': topicDe, 'cefr': cefrLevel, 'phrase_de': graphPhraseDe,
    'phrase_ar': graphPhraseAr, 'audio': audioAssetPath,
  };

  static bool evaluateGraph(String nodeCount) => nodeCount.trim().isNotEmpty;
}
