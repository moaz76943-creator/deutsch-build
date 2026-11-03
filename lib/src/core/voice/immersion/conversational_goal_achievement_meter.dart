/// Task 1186: Calculates mission completion percentage
class GoalAchievementMeter {
  int completedObjectives = 0;
  int totalObjectives = 3;
  void recordObjectiveMet() => completedObjectives++;
  double get progressPercentage => (completedObjectives / totalObjectives).clamp(0.0, 1.0) * 100.0;
}
