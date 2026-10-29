import 'package:flutter/material.dart';

/// A container that safely wraps text content. It guarantees that text can wrap to the
/// next line without overflowing horizontally.
class ResilientTextContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;

  const ResilientTextContainer({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.alignment = Alignment.centerLeft, // Default safe alignment
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Align(
        alignment: alignment,
        // The child (usually a Column of text) will naturally wrap if we provide bounded
        // constraints. SingleChildScrollView horizontal disables wrapping.
        // We ensure horizontal bounds and let vertical expand if needed.
        child: SizedBox(
          width: double.infinity,
          child: child,
        ),
      ),
    );
  }
}
