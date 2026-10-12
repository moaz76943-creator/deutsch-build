import 'package:flutter/material.dart';

class ResilientTextContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BoxDecoration? decoration;

  const ResilientTextContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(8.0),
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: decoration,
      child: child,
    );
  }
}
