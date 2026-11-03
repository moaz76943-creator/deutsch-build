/// Task 1182: Multi-party conversation turns orchestrator
class ImmersionStageDirector {
  final List<String> interlocutors = [];
  void addInterlocutor(String name) => interlocutors.add(name);
  String getNextSpeaker(int turnIndex) => interlocutors.isNotEmpty ? interlocutors[turnIndex % interlocutors.length] : 'AI_GUIDE';
}
