/// Task 2043: Raft leader election coordinator selecting game master for offline quiz battles
class QuizGameMasterElectionRaft {
  String electLeader(List<String> candidates) => candidates.isNotEmpty ? candidates.first : 'self';
}
