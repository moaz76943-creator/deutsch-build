import 'package:flutter/material.dart';

import '../contracts/ui_state.dart';

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
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(semanticsLabel: 'Loading'),
            );
        break;
      case UIStateType.empty:
        content = emptyBuilder?.call(context, state.message) ??
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                state.message ?? 'No offline content available.',
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            );
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
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.message != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      state.message!,
                      style: const TextStyle(color: Colors.orange),
                      textAlign: TextAlign.center,
                      softWrap: true,
                    ),
                  ),
                dataBuilder(context, state.data as T),
              ],
            );
        break;
      case UIStateType.failed:
      case UIStateType.corrupted:
        final error = state.rawError ?? state.failure ?? StateError('Unknown');
        content = errorBuilder?.call(context, error, state.message) ??
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, semanticLabel: 'Error'),
                  const SizedBox(height: 8),
                  Text(
                    state.message ?? 'Unable to load content.',
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ],
              ),
            );
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
