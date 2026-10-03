import 'package:flutter/material.dart';

import '../../application/gamification_notifier.dart';
import 'badges_showcase_screen.dart';

@Deprecated('Use BadgesShowcaseScreen.')
final class BadgesGridScreen extends StatelessWidget {
  const BadgesGridScreen({
    required this.state,
    super.key,
  });

  final GamificationViewState state;

  @override
  Widget build(BuildContext context) => BadgesShowcaseScreen(state: state);
}
