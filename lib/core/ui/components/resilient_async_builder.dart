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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant ResilientAsyncBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
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
}
