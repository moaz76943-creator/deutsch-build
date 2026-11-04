import 'dart:async';

import 'package:flutter/material.dart';

import '../../architecture/operation_result.dart';
import '../contracts/ui_state.dart';
import '../contracts/ui_state_contract.dart';
import 'content_cancellation_token.dart';
import 'resilient_state_builder.dart';

/// An on-screen, bounded and cancellation-aware view of one offline request.
/// Cancellation prevents stale UI updates; it cannot abort arbitrary I/O.
class ResilientAsyncBuilder<T> extends StatefulWidget {
  const ResilientAsyncBuilder({
    super.key,
    this.futureBuilder,
    this.dataBuilder,
    this.fetcher,
    this.builder,
    this.featureName,
    this.requestKey,
    this.timeout = const Duration(seconds: 10),
    this.emptyMessage,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
  }) : assert((futureBuilder != null && dataBuilder != null) ||
            (fetcher != null && builder != null));

  final Future<T?> Function(ContentCancellationToken token)? futureBuilder;
  final Widget Function(BuildContext context, T data)? dataBuilder;
  final Future<UiState<T>> Function(ContentCancellationToken token)? fetcher;
  final Widget Function(BuildContext context, T data)? builder;
  final String? featureName;
  final Object? requestKey;
  final Duration timeout;
  final String? emptyMessage;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, String? message)? emptyBuilder;
  final Widget Function(BuildContext context, Object error, String? message)?
      errorBuilder;

  @override
  State<ResilientAsyncBuilder<T>> createState() =>
      _ResilientAsyncBuilderState<T>();
}

class _ResilientAsyncBuilderState<T> extends State<ResilientAsyncBuilder<T>> {
  ContentCancellationToken? _active;
  UIState<T> _state = UIState<T>.loading();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ResilientAsyncBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.requestKey != widget.requestKey ||
        oldWidget.futureBuilder != widget.futureBuilder ||
        oldWidget.fetcher != widget.fetcher ||
        oldWidget.timeout != widget.timeout) {
      _load();
    }
  }

  void _load() {
    _active?.cancel();
    final token = ContentCancellationToken();
    _active = token;
    _state = UIState<T>.loading();
    if (widget.fetcher != null) {
      Future<UiState<T>>.sync(() => widget.fetcher!(token))
          .timeout(widget.timeout)
          .then((result) {
        if (!mounted || token.isCancelled) return;
        setState(() {
          if (result is UiStateSuccess<T>) {
            _state = UIState<T>.data(result.data);
          } else if (result is UiStateEmpty<T>) {
            _state = UIState<T>.empty(result.message ?? widget.emptyMessage);
          } else if (result is UiStateDegraded<T>) {
            _state = UIState<T>.degraded(result.data,
                message: result.warningMessage);
          } else if (result is UiStateFailed<T>) {
            _state = UIState<T>.failed(
              ContentFailure('ui_async_failure',
                  result.userMessage ?? 'Offline request failed'),
              result.userMessage ?? 'Unable to load content.',
            );
          } else {
            _state = UIState<T>.failed(
              const ContentFailure(
                  'ui_nonterminal_result', 'Request returned a loading state'),
              'Unable to load content.',
            );
          }
        });
      }, onError: (Object error, StackTrace stack) {
        if (!mounted || token.isCancelled) return;
        if (error is TimeoutException) token.cancel();
        setState(() {
          _state = UIState<T>.failed(
            const ContentFailure('ui_async_failure', 'Offline request failed'),
            'Unable to load content.',
          );
        });
      });
    } else {
      Future<T?>.sync(() => widget.futureBuilder!(token))
          .timeout(widget.timeout)
          .then((result) {
        if (!mounted || token.isCancelled) return;
        setState(() {
          _state = result == null
              ? UIState<T>.empty(widget.emptyMessage)
              : UIState<T>.data(result);
        });
      }, onError: (Object error, StackTrace stack) {
        if (!mounted || token.isCancelled) return;
        if (error is TimeoutException) token.cancel();
        setState(() {
          if (error is StorageFailure) {
            _state = UIState<T>.corrupted(
              error,
              'Local content cannot be read.',
            );
          } else if (error is ContentFailure) {
            _state = UIState<T>.empty(widget.emptyMessage);
          } else {
            _state = UIState<T>.failed(
              const ContentFailure(
                  'ui_async_failure', 'Offline request failed'),
              'Unable to load content.',
            );
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _active?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ResilientStateBuilder<T>(
        state: _state,
        dataBuilder: widget.dataBuilder ?? widget.builder!,
        loadingBuilder: widget.loadingBuilder,
        emptyBuilder: widget.emptyBuilder,
        errorBuilder: widget.errorBuilder,
      );
}

/// Adapts a typed domain result without writing progress or SRS state.
class ResilientOperationBuilder<T> extends StatefulWidget {
  const ResilientOperationBuilder({
    super.key,
    required this.operation,
    required this.dataBuilder,
    this.degradedBuilder,
    this.requestKey,
    this.timeout = const Duration(seconds: 10),
  });

  final Future<OperationResult<T>> Function(ContentCancellationToken token)
      operation;
  final Widget Function(BuildContext context, T data) dataBuilder;
  final Widget Function(BuildContext context, T data, String? message)?
      degradedBuilder;
  final Object? requestKey;
  final Duration timeout;

  @override
  State<ResilientOperationBuilder<T>> createState() =>
      _ResilientOperationBuilderState<T>();
}

class _ResilientOperationBuilderState<T>
    extends State<ResilientOperationBuilder<T>> {
  ContentCancellationToken? _active;
  UIState<T> _state = UIState<T>.loading();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ResilientOperationBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.requestKey != widget.requestKey ||
        oldWidget.operation != widget.operation ||
        oldWidget.timeout != widget.timeout) {
      _load();
    }
  }

  void _load() {
    _active?.cancel();
    final token = ContentCancellationToken();
    _active = token;
    _state = UIState<T>.loading();
    Future<OperationResult<T>>.sync(() => widget.operation(token))
        .timeout(widget.timeout)
        .then((result) {
      if (!mounted || token.isCancelled) return;
      setState(() {
        if (result.isSuccess) {
          // The result contract permits a null payload even when marked
          // successful. Never let its force-unwrapping getter escape as an
          // uncaught exception from a Future completion callback.
          try {
            final value = result.data;
            if (value == null) {
              _state = UIState<T>.failed(
                const ContentFailure(
                  'ui_invalid_success',
                  'The operation returned no data',
                ),
                'Unable to load content.',
              );
            } else {
              _state = UIState<T>.data(value);
            }
          } catch (_) {
            _state = UIState<T>.failed(
              const ContentFailure(
                'ui_invalid_success',
                'The operation returned no usable data',
              ),
              'Unable to load content.',
            );
          }
          return;
        }
        final failure = result.failure;
        if (failure is StorageFailure) {
          _state = UIState<T>.corrupted(
            failure,
            'Local content cannot be read.',
          );
        } else if (failure is ContentFailure) {
          _state = UIState<T>.empty('No offline content available.');
        } else {
          _state = UIState<T>.failed(failure, 'Unable to load content.');
        }
      });
    }, onError: (Object error, StackTrace stack) {
      if (!mounted || token.isCancelled) return;
      setState(() {
        _state = UIState<T>.failed(
          const ContentFailure(
              'ui_operation_failure', 'Offline operation failed'),
          'Unable to load content.',
        );
      });
    });
  }

  @override
  void dispose() {
    _active?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ResilientStateBuilder<T>(
        state: _state,
        dataBuilder: widget.dataBuilder,
        degradedBuilder: widget.degradedBuilder,
      );
}
