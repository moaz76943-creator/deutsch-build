import 'package:flutter/material.dart';

<<<<<<< HEAD
/// A container that safely wraps text content. It guarantees that text can wrap to the
/// next line without overflowing horizontally.
class ResilientTextContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;
=======
class ResilientTextContainer extends StatelessWidget {
  final Widget child;
  final double minHeight;
  final EdgeInsetsGeometry padding;
>>>>>>> origin/main

  const ResilientTextContainer({
    super.key,
    required this.child,
<<<<<<< HEAD
    this.padding = EdgeInsets.zero,
    this.alignment = Alignment.centerLeft, // Default safe alignment
=======
    this.minHeight = 48.0,
    this.padding = const EdgeInsets.all(12.0),
>>>>>>> origin/main
  });

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
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
=======
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Container(
        padding: padding,
        child: child,
>>>>>>> origin/main
      ),
    );
  }
}
