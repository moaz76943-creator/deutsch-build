import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../../design_system/design_system.dart';
import '../contracts/ui_state_contract.dart';
import 'resilient_async_builder.dart';
import 'content_cancellation_token.dart';

class OptionalMediaWidget extends StatelessWidget {
  final Future<Uint8List?> Function() fetcher;
  final String semanticLabel;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? fallbackIcon;

  const OptionalMediaWidget({
    super.key,
    required this.fetcher,
    required this.semanticLabel,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackIcon,
  });

  Future<UiState<Uint8List>> _loadMedia(ContentCancellationToken token) async {
    try {
      final data = await fetcher();
      if (data == null || data.isEmpty) {
        return const UiStateEmpty('Media missing');
      }
      return UiStateSuccess(data);
    } catch (e, st) {
      return UiStateFailed(e,
          stackTrace: st, userMessage: 'Failed to load media');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ResilientAsyncBuilder<Uint8List>(
        featureName: 'Optional Media',
        fetcher: _loadMedia,
        builder: (context, data) {
          return Image.memory(
            data,
            fit: fit,
            semanticLabel: semanticLabel,
            errorBuilder: (context, error, stackTrace) =>
                _buildFallback(context),
          );
        },
        emptyBuilder: (context, message) =>
            _buildFallback(context, isError: false),
        errorBuilder: (context, error, message) =>
            _buildFallback(context, isError: true),
      ),
    );
  }

  Widget _buildFallback(BuildContext context, {bool isError = false}) {
    return Semantics(
      label: semanticLabel,
      image: true,
      excludeSemantics: true,
      child: Container(
        color: Colors.grey.shade200,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              fallbackIcon ??
                  Icon(
                    isError ? Icons.broken_image : Icons.image_not_supported,
                    size: 32,
                    color: Colors.grey.shade500,
                  ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  semanticLabel,
                  style: AppTypography.caption,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
