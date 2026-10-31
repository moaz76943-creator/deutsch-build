import '../models/learner.dart';
import 'adaptive_teacher.dart';

class DailyPlan {
  final int total, review, repair, newContent, listening, production;
  final String focusSkill;
  const DailyPlan({
    required this.total,
    required this.review,
    required this.repair,
    required this.newContent,
    required this.listening,
    required this.production,
    required this.focusSkill,
  });

  factory DailyPlan.from(LearnerState state, {DateTime? now, int goal = 10}) {
    final boundedGoal = goal.clamp(5, 20).toInt();
    final due = state.meaningReviewCards
        .where((c) => !c.dueAt.isAfter(now ?? DateTime.now()))
        .length;
    final action = AdaptiveTeacher.next(state, now: now);
    final review = due.clamp(0, (boundedGoal * .5).round()).toInt();
    final repair = action.type == TeacherActionType.repair
        ? ((boundedGoal - review) * .45).round()
        : ((boundedGoal - review) * .25).round();
    final newContent =
        (boundedGoal - review - repair).clamp(0, boundedGoal).toInt();
    final listening = (boundedGoal * .15).round();
    final production = (boundedGoal * .25).round();
    return DailyPlan(
      total: boundedGoal,
      review: review,
      repair: repair,
      newContent: newContent,
      listening: listening,
      production: production,
      focusSkill: action.skill,
    );
  }
}
