import 'package:flutter/material.dart';

import '../contracts/ui_state.dart';
import '../states/content_loading_state.dart';
import '../states/content_empty_state.dart';
import '../states/content_error_state.dart';

/// Presents a typed offline-content state without altering route or domain state.
class ResilientStateBuilder<T> extends StatelessWidget {
  const ResilientStateBuilder({
    super.key,
    required this.state,
    required this.dataBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    this.degradedBuilder,
    this.errorBuilder,
  });

  final UIState<T> state;
  final Widget Function(BuildContext context, T data) dataBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, String? message)? emptyBuilder;
  final Widget Function(BuildContext context, T data, String? message)?
      degradedBuilder;
  final Widget Function(BuildContext context, Object error, String? message)?
      errorBuilder;

  @override
  Widget build(BuildContext context) {
    final Widget content;
    switch (state.type) {
      case UIStateType.loading:
        content = loadingBuilder?.call(context) ??
            const ContentLoadingState(message: 'Loading...');
        break;
      case UIStateType.empty:
        content = emptyBuilder?.call(context, state.message) ??
            ContentEmptyState(message: state.message ?? 'No offline content available.');
        break;
      case UIStateType.data:
        content = dataBuilder(context, state.data as T);
        break;
      case UIStateType.degraded:
        content = degradedBuilder?.call(
              context,
              state.data as T,
              state.message,
            ) ??
            dataBuilder(context, state.data as T);
        break;
      case UIStateType.failed:
      case UIStateType.corrupted:
        final error = state.rawError ?? state.failure ?? StateError('Unknown');
        content = errorBuilder?.call(context, error, state.message) ??
            ContentErrorState(error: error);
        break;
    }
    if (state.type == UIStateType.data || state.type == UIStateType.degraded) {
      return content;
    }
    // Default status content may grow at large text scales. Do not
    // constrain dataBuilder, which owns scrolling for its data view.
    return LayoutBuilder(builder: (context, constraints) {
      if (!constraints.hasBoundedHeight) return content;
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(child: content),
        ),
      );
    });
  }
}
