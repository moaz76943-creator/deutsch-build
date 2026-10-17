import 'package:flutter/material.dart';
import '../states/content_error_state.dart';
import '../states/content_loading_state.dart';

class ResilientAsyncBuilder<T> extends StatefulWidget {
  final Future<T> Function() futureFactory;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;

  const ResilientAsyncBuilder({
    super.key,
    required this.futureFactory,
    required this.builder,
    this.errorBuilder,
    this.loadingBuilder,
  });

  @override
  State<ResilientAsyncBuilder<T>> createState() => _ResilientAsyncBuilderState<T>();
}

class _ResilientAsyncBuilderState<T> extends State<ResilientAsyncBuilder<T>> {
  late Future<T> _future;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initFuture();
  }

  @override
  void didUpdateWidget(ResilientAsyncBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.futureFactory != widget.futureFactory) {
      _initFuture();
    }
  }

  void _initFuture() {
    _future = widget.futureFactory();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.loadingBuilder?.call(context) ?? const ContentLoadingState();
        }

        if (snapshot.hasError) {
          return widget.errorBuilder?.call(context, snapshot.error!) ??
              ContentErrorState(
                error: snapshot.error!,
                onRetry: () {
                  if (!_isDisposed) {
                    setState(() {
                      _initFuture();
                    });
                  }
                },
              );
        }

        if (snapshot.hasData) {
          return widget.builder(context, snapshot.data as T);
        }

        return const SizedBox.shrink();
      },
    );
  }
}
