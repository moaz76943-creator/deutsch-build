import 'dart:async';
import 'package:flutter/material.dart';
import '../../architecture/operation_result.dart';
import '../contracts/ui_state.dart';
import 'content_cancellation_token.dart';
import 'resilient_state_builder.dart';

class ResilientAsyncBuilder<T> extends StatefulWidget {
  final Future<T?> Function(ContentCancellationToken token) futureBuilder;
  final Widget Function(BuildContext context, T data) dataBuilder;
  final Duration timeout;
  final String? emptyMessage;

  const ResilientAsyncBuilder({
    super.key,
    required this.futureBuilder,
    required this.dataBuilder,
    this.timeout = const Duration(seconds: 10),
    this.emptyMessage,
  });

  @override
  State<ResilientAsyncBuilder<T>> createState() => _ResilientAsyncBuilderState<T>();
}

class _ResilientAsyncBuilderState<T> extends State<ResilientAsyncBuilder<T>> {
  late ContentCancellationToken _cancellationToken;
  UIState<T> _state = UIState<T>.loading();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    _cancellationToken = ContentCancellationToken();
    _state = UIState<T>.loading();

    widget.futureBuilder(_cancellationToken).timeout(
      widget.timeout,
    ).then((result) {
      if (_cancellationToken.isCancelled) return;

      if (mounted) {
        setState(() {
          if (result == null) {
            _state = UIState<T>.empty(widget.emptyMessage);
          } else {
            _state = UIState<T>.data(result);
          }
        });
      }
    }).catchError((error) {
      if (_cancellationToken.isCancelled) return;

      if (mounted) {
        setState(() {
          if (error is StorageFailure) {
            _state = UIState<T>.corrupted(error, 'Storage data corruption detected.');
          } else if (error is ContentFailure) {
            _state = UIState<T>.empty(widget.emptyMessage ?? 'Content not found.');
          } else {
            _state = UIState<T>.failed(ContentFailure('async_error', error.toString()), 'An unexpected error occurred.');
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _cancellationToken.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResilientStateBuilder<T>(
      state: _state,
      dataBuilder: widget.dataBuilder,
    );
  }
}

class ResilientOperationBuilder<T> extends StatefulWidget {
  final Future<OperationResult<T>> Function(ContentCancellationToken token) operation;
  final Widget Function(BuildContext context, T data) dataBuilder;
  final Widget Function(BuildContext context, T data, String? message)? degradedBuilder;
  final Duration timeout;

  const ResilientOperationBuilder({
    super.key,
    required this.operation,
    required this.dataBuilder,
    this.degradedBuilder,
    this.timeout = const Duration(seconds: 10),
  });

  @override
  State<ResilientOperationBuilder<T>> createState() => _ResilientOperationBuilderState<T>();
}

class _ResilientOperationBuilderState<T> extends State<ResilientOperationBuilder<T>> {
  late ContentCancellationToken _cancellationToken;
  UIState<T> _state = UIState<T>.loading();

  @override
  void initState() {
    super.initState();
    _executeOperation();
  }

  void _executeOperation() {
    _cancellationToken = ContentCancellationToken();
    _state = UIState<T>.loading();

    widget.operation(_cancellationToken).timeout(
      widget.timeout,
    ).then((result) {
      if (_cancellationToken.isCancelled) return;

      if (mounted) {
        setState(() {
          if (result.isSuccess) {
            _state = UIState<T>.data(result.data);
          } else {
            final failure = result.failure;
            if (failure is StorageFailure) {
              _state = UIState<T>.corrupted(failure, 'Storage corruption detected.');
            } else if (failure is ContentFailure) {
              _state = UIState<T>.empty('Content missing.');
            } else {
               _state = UIState<T>.failed(failure, 'Operation failed.');
            }
          }
        });
      }
    }).catchError((error) {
      if (_cancellationToken.isCancelled) return;

      if (mounted) {
        setState(() {
           _state = UIState<T>.failed(ContentFailure('async_error', error.toString()), 'An unexpected error occurred.');
        });
      }
    });
  }

  @override
  void dispose() {
    _cancellationToken.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResilientStateBuilder<T>(
      state: _state,
      dataBuilder: widget.dataBuilder,
      degradedBuilder: widget.degradedBuilder,
    );
  }
}
