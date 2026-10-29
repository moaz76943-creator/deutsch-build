import 'package:flutter/material.dart';

import '../../domain/achievement_models.dart';
import 'streak_status_widget.dart';

@Deprecated('Use StreakStatusWidget.')
final class StreakFlameGlassWidget extends StatelessWidget {
  const StreakFlameGlassWidget({
    required this.streak,
    super.key,
  });

  final UserStreak streak;

  @override
  Widget build(BuildContext context) => StreakStatusWidget(streak: streak);
}
