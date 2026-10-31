import 'package:flutter/material.dart';

import 'phase6_l10n_controller.dart';

final class LocalizedTaskRouteHost extends StatelessWidget {
  const LocalizedTaskRouteHost({
    required this.controller,
    required this.childBuilder,
    super.key,
  });

  final Phase6L10nController controller;
  final WidgetBuilder childBuilder;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (context, _) => Directionality(
          textDirection: controller.textDirection,
          child: childBuilder(context),
        ),
      );
}
