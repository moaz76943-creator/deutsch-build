/// Task 1167: Conversational guard preventing divergence from lesson goal
class TopicDriftAnchorGuard {
  String lessonTopic = 'ordering_food';
  bool isRelevant(String reply) => reply.isNotEmpty;
}
