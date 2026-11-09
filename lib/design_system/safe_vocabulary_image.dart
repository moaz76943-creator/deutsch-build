import 'package:flutter/material.dart';

/// Right-sized image widget for vocabulary cards, packs, and media.
///
/// Always decodes images at (or near) the size they will be displayed,
/// avoiding the common Flutter pitfall of decoding full-resolution bitmaps
/// into the ImageCache. This is the single highest-leverage memory and jank
/// optimization for image-heavy offline learning sessions.
///
/// Usage:
/// ```dart
/// SafeVocabularyImage(
///   image: AssetImage('assets/media/example.webp'),
///   width: 120,
///   height: 80,
/// )
/// ```
///
/// Prefer this over raw Image.asset / Image.file / CachedNetworkImage
/// for any vocabulary or content image.
class SafeVocabularyImage extends StatelessWidget {
  final ImageProvider image;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const SafeVocabularyImage({
    super.key,
    required this.image,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = width != null ? (width! * dpr).round() : null;
    final cacheHeight = height != null ? (height! * dpr).round() : null;

    return Image(
      image: image,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return placeholder ?? const SizedBox.shrink();
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ??
            const Icon(Icons.broken_image_outlined, color: Colors.grey);
      },
      // Exclude from semantics when decorative; callers can wrap if needed.
      excludeFromSemantics: true,
    );
  }
}
