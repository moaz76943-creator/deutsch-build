import 'package:flutter/material.dart';

import 'content_cancellation_token.dart';
import 'resilient_async_builder.dart';

/// Optional offline media that remains accessible when an asset is unavailable.
class ResilientMediaContent extends StatelessWidget {
  const ResilientMediaContent({
    super.key,
    required this.mediaFetcher,
    required this.fallbackSemanticLabel,
    this.customFallback,
    this.requestKey,
    this.timeout = const Duration(seconds: 5),
    this.width,
    this.height,
  });

  final Future<Widget?> Function(ContentCancellationToken token) mediaFetcher;
  final String fallbackSemanticLabel;
  final Widget? customFallback;
  final Object? requestKey;
  final Duration timeout;
  final double? width;
  final double? height;

  Widget _fallback(BuildContext context) => Semantics(
        label: fallbackSemanticLabel,
        child: SizedBox(
          width: width,
          height: height,
          child: customFallback ??
              const Center(child: Icon(Icons.image_not_supported)),
        ),
      );

  @override
  Widget build(BuildContext context) => ResilientAsyncBuilder<Widget>(
        requestKey: requestKey,
        futureBuilder: mediaFetcher,
        timeout: timeout,
        dataBuilder: (context, data) => Semantics(
          label: fallbackSemanticLabel,
          child: SizedBox(width: width, height: height, child: data),
        ),
        loadingBuilder: (context) => SizedBox(
          width: width,
          height: height,
          child: const Center(child: CircularProgressIndicator()),
        ),
        emptyBuilder: (context, message) => _fallback(context),
        errorBuilder: (context, error, message) => _fallback(context),
      );
}
