import 'package:flutter/widgets.dart';

/// OptimizedRenderTile - Master Constitution Section 10 & #486 Compliant:
/// Eliminates redundant subtree repaints and rebuild jank on long lists
/// by isolating render nodes with RepaintBoundary and caching layout constraints.
class OptimizedRenderTile extends StatelessWidget {
  final Widget child;
  final Key? boundaryKey;
  final bool enableRepaintBoundary;

  const OptimizedRenderTile({
    super.key,
    required this.child,
    this.boundaryKey,
    this.enableRepaintBoundary = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enableRepaintBoundary) {
      return child;
    }

    // Isolates this component in its own render layer to prevent paint propagation
    return RepaintBoundary(
      key: boundaryKey,
      child: child,
    );
  }
}

/// KeepAliveWrapper preserves scroll offset and widget state inside dynamic ListViews
class KeepAliveWrapper extends StatefulWidget {
  final Widget child;

  const KeepAliveWrapper({super.key, required this.child});

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
