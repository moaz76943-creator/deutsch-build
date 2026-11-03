/// Task 1176: Branching state graph for situational immersion roleplays
class RoleplayStateGraph {
  final Map<String, List<String>> _transitions = {};
  void addBranch(String state, List<String> nextStates) => _transitions[state] = nextStates;
  List<String> getNext(String current) => _transitions[current] ?? [];
}
