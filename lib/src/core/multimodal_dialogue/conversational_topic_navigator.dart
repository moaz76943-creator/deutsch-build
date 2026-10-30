/// Conversational topic node with semantic transition pathways.
class TopicNode {
  final String topicId;
  final String title;
  final List<String> targetVocabulary;
  final List<String> connectedTopicIds;
  final List<String> openQuestions;

  const TopicNode({
    required this.topicId,
    required this.title,
    required this.targetVocabulary,
    required this.connectedTopicIds,
    required this.openQuestions,
  });
}

/// Steers live conversational practice organically across connected topical domains.
class ConversationalTopicNavigator {
  final Map<String, TopicNode> _topics = {
    'food': const TopicNode(
      topicId: 'food',
      title: 'Essen und Kochen',
      targetVocabulary: ['Küche', 'Rezept', 'köstlich', 'zubereiten'],
      connectedTopicIds: ['culture', 'travel', 'health'],
      openQuestions: [
        'Was kochst du am liebsten, wenn du Zeit hast?',
        'Welches traditionelle Gericht aus deiner Heimat magst du besonders?',
      ],
    ),
    'travel': const TopicNode(
      topicId: 'travel',
      title: 'Reisen und Städte',
      targetVocabulary: ['Zug', 'Flughafen', 'Sehenswürdigkeit', 'erkunden'],
      connectedTopicIds: ['food', 'culture', 'nature'],
      openQuestions: [
        'Welche Stadt in Deutschland möchtest du unbedingt besuchen?',
        'Reist du lieber mit dem Zug oder mit dem Flugzeug?',
      ],
    ),
  };

  /// Proposes an organic segue question from the current topic to keep the conversation flowing.
  String suggestFollowUpQuestion(String currentTopicId) {
    final topic = _topics[currentTopicId.toLowerCase()];
    if (topic == null || topic.openQuestions.isEmpty) {
      return 'Erzähl mir mehr darüber! Was denkst du?';
    }
    return topic.openQuestions.first;
  }

  /// Finds logical next topic based on semantic connectivity.
  String suggestNextTopic(String currentTopicId) {
    final topic = _topics[currentTopicId.toLowerCase()];
    if (topic == null || topic.connectedTopicIds.isEmpty) {
      return 'travel';
    }
    return topic.connectedTopicIds.first;
  }
}
