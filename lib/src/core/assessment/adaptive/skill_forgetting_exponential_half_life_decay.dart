/// Task 1417: Ebbinghaus exponential forgetting half-life decay function
class SkillDecayModel {
  double calculateRetainedMastery(double initialMastery, int daysElapsed, double halfLifeDays) => initialMastery * (1.0 / (1.0 + (daysElapsed / halfLifeDays)));
}
