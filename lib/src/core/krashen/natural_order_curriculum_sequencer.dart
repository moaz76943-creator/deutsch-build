class NaturalOrderCurriculumSequencer {
  final Set<String> _prereqs = {};
  void registerPrereq(String m) => _prereqs.add(m);
  bool isAdmissible(String m, Set<String> mastered) => mastered.containsAll(_prereqs);
}
