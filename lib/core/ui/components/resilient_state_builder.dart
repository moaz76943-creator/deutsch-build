import 'package:flutter/material.dart';
import '../contracts/ui_state.dart';

class ResilientStateBuilder<T> extends StatelessWidget {
  final UIState<T> state;
  final Widget Function(BuildContext context, T data) dataBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, String? message)? emptyBuilder;
  final Widget Function(BuildContext context, T data, String? message)? degradedBuilder;
  final Widget Function(BuildContext context, Object error, String? message)? errorBuilder;

  const ResilientStateBuilder({
    super.key,
    required this.state,
    required this.dataBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    this.degradedBuilder,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Widget content;

        switch (state.type) {
          case UIStateType.loading:
            content = loadingBuilder?.call(context) ?? _defaultLoading(context);
            break;
          case UIStateType.empty:
            content = emptyBuilder?.call(context, state.message) ?? _defaultEmpty(context, state.message);
            break;
          case UIStateType.data:
            content = dataBuilder(context, state.data as T);
            break;
          case UIStateType.degraded:
            content = degradedBuilder?.call(context, state.data as T, state.message) ?? dataBuilder(context, state.data as T);
            break;
          case UIStateType.failed:
          case UIStateType.corrupted:
            content = errorBuilder?.call(context, state.rawError ?? state.failure ?? 'Unknown Error', state.message) ??
                _defaultError(context, state.rawError ?? state.failure ?? 'Unknown Error', state.message);
            break;
        }
        // Only wrap with SingleChildScrollView if we have bounded height constraints.
        if (!constraints.hasBoundedHeight) {
          return content;
        }

        // To prevent overflow in constrained environments, we wrap with SingleChildScrollView
        // Only force scroll for default states to prevent overflow. dataBuilder handles its own scrolling.
        if (state.type != UIStateType.data && state.type != UIStateType.degraded) {
           return SingleChildScrollView(
             child: ConstrainedBox(
               constraints: BoxConstraints(minHeight: constraints.maxHeight),
               child: Center(child: content),
             ),
           );
        }

        return content;
      },
    );
  }

  Widget _defaultLoading(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: CircularProgressIndicator(semanticsLabel: 'Loading'),
    );
  }

  Widget _defaultEmpty(BuildContext context, String? message) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        message ?? 'No content available.',
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _defaultError(BuildContext context, Object error, String? message) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48, semanticLabel: 'Error'),
          const SizedBox(height: 16),
          Text(
            message ?? 'An error occurred.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
