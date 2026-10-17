<<<<<<< HEAD
import 'package:flutter/material.dart';
import '../../resilience/feature_boundary.dart';
import '../../../design_system/design_system.dart';
import '../contracts/ui_state_contract.dart';

class ResilientAsyncBuilder<T> extends StatefulWidget {
  final Future<UiState<T>> Function() fetcher;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context, T data, String warningMessage)? degradedBuilder;
  final Widget Function(BuildContext context, String? message)? emptyBuilder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final String featureName;

  const ResilientAsyncBuilder({
    super.key,
    required this.fetcher,
    required this.builder,
    required this.featureName,
    this.degradedBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.loadingBuilder,
  });

  @override
  State<ResilientAsyncBuilder<T>> createState() => _ResilientAsyncBuilderState<T>();
}

class _ResilientAsyncBuilderState<T> extends State<ResilientAsyncBuilder<T>> {
  UiState<T> _state = const UiStateLoading();
=======
import 'dart:async';

import 'package:flutter/material.dart';

import '../../architecture/operation_result.dart';
import '../contracts/ui_state.dart';
import 'content_cancellation_token.dart';
import 'resilient_state_builder.dart';

/// An on-screen, bounded and cancellation-aware view of one offline request.
/// Cancellation prevents stale UI updates; it cannot abort arbitrary I/O.
class ResilientAsyncBuilder<T> extends StatefulWidget {
  const ResilientAsyncBuilder({
    super.key,
    required this.futureBuilder,
    required this.dataBuilder,
    this.requestKey,
    this.timeout = const Duration(seconds: 10),
    this.emptyMessage,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
  });

  final Future<T?> Function(ContentCancellationToken token) futureBuilder;
  final Widget Function(BuildContext context, T data) dataBuilder;
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
>>>>>>> pr-179

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _loadData();
=======
    _load();
>>>>>>> pr-179
  }

  @override
  void didUpdateWidget(covariant ResilientAsyncBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
<<<<<<< HEAD
    if (widget.fetcher != oldWidget.fetcher) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _state = const UiStateLoading();
    });

    try {
      final result = await widget.fetcher();
      if (!mounted) return;
      setState(() {
        _state = result;
      });
    } catch (e, st) {
      if (!mounted) return;
      setState(() {
        _state = UiStateFailed(e, stackTrace: st);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FeatureBoundary(
      featureName: widget.featureName,
      fallbackBuilder: widget.errorBuilder,
      child: Semantics(
        container: true,
        child: Focus(
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return switch (_state) {
      UiStateLoading() => widget.loadingBuilder?.call(context) ??
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          ),
      UiStateEmpty(:final message) => widget.emptyBuilder?.call(context, message) ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    message ?? 'No content available',
                    style: AppTypography.body,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      UiStateSuccess(:final data) => widget.builder(context, data),
      UiStateDegraded(:final data, :final warningMessage) =>
          widget.degradedBuilder?.call(context, data, warningMessage) ??
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.amber.shade100,
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            warningMessage,
                            style: AppTypography.caption,
                          ),
                        ),
                      ],
                    ),
                  ),
                  widget.builder(context, data),
                ],
              ),
      UiStateFailed(:final error, :final userMessage) =>
          widget.errorBuilder?.call(context, error) ??
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                      const SizedBox(height: 16),
                      Text(
                        userMessage ?? 'Failed to load content',
                        style: AppTypography.body.copyWith(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
    };
  }
=======
    if (oldWidget.requestKey != widget.requestKey ||
        oldWidget.futureBuilder != widget.futureBuilder ||
        oldWidget.timeout != widget.timeout) {
      _load();
    }
  }

  void _load() {
    _active?.cancel();
    final token = ContentCancellationToken();
    _active = token;
    _state = UIState<T>.loading();
    Future<T?>.sync(() => widget.futureBuilder(token))
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
            ContentFailure('ui_async_failure', 'Offline request failed'),
            'Unable to load content.',
          );
        }
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
          ContentFailure('ui_operation_failure', 'Offline operation failed'),
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
>>>>>>> pr-179
}
