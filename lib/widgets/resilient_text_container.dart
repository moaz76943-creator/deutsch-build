import 'package:flutter/material.dart';

class ResilientTextContainer extends StatelessWidget {
  final Widget child;
  final double minHeight;
  final EdgeInsetsGeometry padding;

  const ResilientTextContainer({
    super.key,
    required this.child,
    this.minHeight = 48.0,
    this.padding = const EdgeInsets.all(12.0),
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Container(
        padding: padding,
        child: child,
      ),
    );
  }
}
