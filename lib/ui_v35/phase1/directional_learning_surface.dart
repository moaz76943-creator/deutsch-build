import 'package:flutter/material.dart';

final class DirectionalLearningSurface extends StatelessWidget {
  final Widget child;

  const DirectionalLearningSurface({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const Key('phase1-directional-padding'),
      padding: const EdgeInsetsDirectional.only(start: 24),
      child: Align(
        key: const Key('phase1-directional-align'),
        alignment: AlignmentDirectional.centerStart,
        child: child,
      ),
    );
  }
}
