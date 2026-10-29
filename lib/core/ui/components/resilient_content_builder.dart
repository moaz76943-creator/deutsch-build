import 'dart:async';
import 'package:flutter/material.dart';
import '../contracts/content_state_contract.dart';
import '../tokens/app_spacing.dart';

typedef ContentWidgetBuilder<T> = Widget Function(BuildContext context, T data);
typedef StateWidgetBuilder = Widget Function(BuildContext context);
typedef ErrorWidgetBuilder = Widget Function(BuildContext context, Object error);

class ResilientContentBuilder<T> extends StatefulWidget {
  final Future<T> Function() fetcher;
  final ContentWidgetBuilder<T> builder;
  final StateWidgetBuilder? loadingBuilder;
  final StateWidgetBuilder? emptyBuilder;
  final ErrorWidgetBuilder? corruptBuilder;
  final ErrorWidgetBuilder? errorBuilder;
  final Duration timeout;
  final bool Function(T)? isEmpty;

  const ResilientContentBuilder({
    super.key,
    required this.fetcher,
    required this.builder,
    this.loadingBuilder,
    this.emptyBuilder,
    this.corruptBuilder,
    this.errorBuilder,
    this.timeout = const Duration(seconds: 15),
    this.isEmpty,
  });

  @override
  State<ResilientContentBuilder<T>> createState() => _ResilientContentBuilderState<T>();
}

class _ResilientContentBuilderState<T> extends State<ResilientContentBuilder<T>> {
  ContentState _state = ContentState.loading;
  T? _data;
  Object? _error;
  bool _mounted = true;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  @override
  void dispose() {
    _mounted = false;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    super.dispose();
  }

  Future<void> _loadContent() async {
    _timeoutTimer = Timer(widget.timeout, () {
      if (_mounted && _state == ContentState.loading) {
        setState(() {
          _state = ContentState.failed;
          _error = TimeoutException('Operation timed out');
        });
      }
    });

    try {
      final data = await widget.fetcher();
      if (!_mounted) return;

      setState(() {
        _timeoutTimer?.cancel();
        if (_state != ContentState.loading) return; // Prevent overwriting timeout
        _data = data;

        bool empty = false;
        if (widget.isEmpty != null) {
            empty = widget.isEmpty!(data);
        } else if (data is List || data is String || data is Map || data is Set) {
            empty = (data as dynamic).isEmpty;
        }

        if (empty) {
          _state = ContentState.empty;
        } else {
          _state = ContentState.ready;
        }
      });
    } catch (e) {
      if (!_mounted) return;
      _timeoutTimer?.cancel();

      setState(() {
        if (_state != ContentState.loading) return; // Prevent overwriting timeout
        _error = e;
        // Simple heuristic for corrupted data
        if (e.toString().toLowerCase().contains('corrupt') || e is FormatException) {
          _state = ContentState.corrupted;
        } else {
          _state = ContentState.failed;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case ContentState.loading:
        return widget.loadingBuilder?.call(context) ?? _buildDefaultLoading();
      case ContentState.ready:
      case ContentState.degraded: // Treats degraded as ready for this component's scope
        return widget.builder(context, _data as T);
      case ContentState.empty:
        return widget.emptyBuilder?.call(context) ?? _buildDefaultEmpty();
      case ContentState.corrupted:
        return widget.corruptBuilder?.call(context, _error!) ?? _buildDefaultError('Data Corrupted');
      case ContentState.failed:
        return widget.errorBuilder?.call(context, _error!) ?? _buildDefaultError('Operation Failed');
    }
  }

  Widget _buildDefaultLoading() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildDefaultEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Text('No content available'),
      ),
    );
  }

  Widget _buildDefaultError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 32),
            const SizedBox(height: AppSpacing.sm),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
