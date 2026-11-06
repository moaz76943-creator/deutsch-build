import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NeumorphicVocabularyCard extends StatelessWidget {
  final String imageUrl;
  final String heroTag;
  final Widget? child;

  const NeumorphicVocabularyCard({
    super.key,
    required this.imageUrl,
    required this.heroTag,
    this.child,
  });

  void _showZoomedImage(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Center(
                child: Hero(
                  tag: heroTag,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      width: MediaQuery.of(context).size.width * 0.8,
                      // Higher quality for zoom; still bounded to avoid extreme memory spikes
                      memCacheWidth: 1200,
                      memCacheHeight: 900,
                      maxWidthDiskCache: 1600,
                      maxHeightDiskCache: 1200,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(
                          Icons.error,
                          size: 50,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (imageUrl.isNotEmpty) {
          _showZoomedImage(context);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              offset: const Offset(4, 4),
              blurRadius: 10,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.05),
              offset: const Offset(-4, -4),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (imageUrl.isNotEmpty)
              Expanded(
                child: Hero(
                  tag: heroTag,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      // Limit decoded size for list cards: reduces memory pressure,
                      // faster decode, less jank when many cards are visible/scrolling.
                      memCacheWidth: 400,
                      memCacheHeight: 300,
                      maxWidthDiskCache: 800,
                      maxHeightDiskCache: 600,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Center(
                          child: Icon(Icons.error, color: Colors.white54)),
                    ),
                  ),
                ),
              )
            else
              const Expanded(
                child: Center(
                  child: Icon(Icons.image_not_supported,
                      size: 50, color: Colors.white24),
                ),
              ),
            if (child != null)
              Container(
                padding: const EdgeInsets.all(12),
                child: child,
              ),
          ],
        ),
      ),
    );
  }
}
