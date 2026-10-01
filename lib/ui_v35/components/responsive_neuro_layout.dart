import 'package:flutter/material.dart';

/// A responsive wrapper layout enforcing neuro-ergonomic constraints.
///
/// It utilizes [SafeArea] to prevent UI clipping from notches/system UI.
/// It wraps its content in a [ConstrainedBox] to apply max-width constraints
/// (to maintain comfortable reading line lengths on tablets/landscape).
/// The inner content is placed within a scrollable thumb-zone container
/// ([SingleChildScrollView] by default, though content can dictate otherwise)
/// to prevent overflow issues on small devices.
class ResponsiveNeuroLayout extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final bool scrollable;

  /// Creates a [ResponsiveNeuroLayout].
  ///
  /// [maxWidth] defaults to 600.0, which is an optimal reading width for neuro-ergonomic design.
  /// If [scrollable] is true (the default), the layout injects a [SingleChildScrollView].
  const ResponsiveNeuroLayout({
    super.key,
    required this.child,
    this.maxWidth = 600.0,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = scrollable
        ? SingleChildScrollView(
            child: Padding(
              // Ensure thumb-zone padding at the bottom (ergonomic reach).
              padding: const EdgeInsets.only(bottom: 80.0),
              child: child,
            ),
          )
        : child;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: content,
        ),
      ),
    );
  }
}
