import 'package:flutter/material.dart';
import 'content_cancellation_token.dart';
import '../contracts/ui_state.dart';
import 'resilient_state_builder.dart';

class ResilientMediaContent extends StatefulWidget {
  final Future<Widget?> Function(ContentCancellationToken token) mediaFetcher;
  final String fallbackSemanticLabel;
  final Widget? customFallback;
  final Duration timeout;
  final double? width;
  final double? height;

  const ResilientMediaContent({
    super.key,
    required this.mediaFetcher,
    required this.fallbackSemanticLabel,
    this.customFallback,
    this.timeout = const Duration(seconds: 5),
    this.width,
    this.height,
  });

  @override
  State<ResilientMediaContent> createState() => _ResilientMediaContentState();
}

class _ResilientMediaContentState extends State<ResilientMediaContent> {
  late ContentCancellationToken _cancellationToken;
  UIState<Widget> _state = UIState<Widget>.loading();

  @override
  void initState() {
    super.initState();
    _fetchMedia();
  }

  void _fetchMedia() {
    _cancellationToken = ContentCancellationToken();
    _state = UIState<Widget>.loading();

    widget.mediaFetcher(_cancellationToken).timeout(
      widget.timeout,
    ).then((result) {
      if (_cancellationToken.isCancelled) return;
      if (mounted) {
        setState(() {
          if (result == null) {
            _state = UIState<Widget>.empty();
          } else {
            _state = UIState<Widget>.data(result);
          }
        });
      }
    }).catchError((error) {
      if (_cancellationToken.isCancelled) return;
      if (mounted) {
        setState(() {
          _state = UIState<Widget>.empty(); // Error also falls back to empty
        });
      }
    });
  }

  @override
  void dispose() {
    _cancellationToken.cancel();
    super.dispose();
  }

  Widget _buildFallback(BuildContext context) {
    if (widget.customFallback != null) {
      return Semantics(
        label: widget.fallbackSemanticLabel,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: widget.customFallback!,
        ),
      );
    }

    return Semantics(
      label: widget.fallbackSemanticLabel,
      child: Container(
        width: widget.width ?? 100,
        height: widget.height ?? 100,
        color: Colors.grey.shade200,
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            color: Colors.grey.shade400,
            size: (widget.width ?? 100) * 0.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResilientStateBuilder<Widget>(
      state: _state,
      dataBuilder: (context, data) {
        return Semantics(
          label: widget.fallbackSemanticLabel,
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: data,
          ),
        );
      },
      loadingBuilder: (context) => SizedBox(
        width: widget.width ?? 100,
        height: widget.height ?? 100,
        child: const Center(child: CircularProgressIndicator()),
      ),
      emptyBuilder: (context, _) => _buildFallback(context),
      errorBuilder: (context, _, __) => _buildFallback(context),
    );
  }
}
