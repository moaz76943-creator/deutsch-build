import 'package:flutter/material.dart';

class ResilientTextContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;
  final BoxConstraints? constraints;

  const ResilientTextContainer({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.alignment = Alignment.centerLeft,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      alignment: alignment,
      constraints:
          constraints ?? const BoxConstraints(minWidth: 0, minHeight: 0),
      child: LayoutBuilder(
        builder: (context, layoutConstraints) {
          double maxWidth = layoutConstraints.maxWidth;
          // Protect against unbounded widths that would crash CrossAxisAlignment.stretch
          if (maxWidth.isInfinite) {
            final mediaQuery = MediaQuery.maybeOf(context);
            if (mediaQuery != null) {
              maxWidth = mediaQuery.size.width;
            }
          }

          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
            ),
            child: child,
          );
        },
      ),
    );
  }
}
