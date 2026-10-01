import '../models/learner.dart';

class Stats {
  static double score(LearnerState s, String skill) {
    final a = s.attempts.where((x) => x.skill == skill).toList();
    if (a.isEmpty) return 0;
    return a.where((x) => x.correct).length / a.length;
  }

  static int avgSeconds(LearnerState s) {
    if (s.attempts.isEmpty) return 0;
    return (s.attempts.map((x) => x.seconds).reduce((a, b) => a + b) /
            s.attempts.length)
        .round();
  }

  static int completedTopics(LearnerState s) => s.learned.length;
}
