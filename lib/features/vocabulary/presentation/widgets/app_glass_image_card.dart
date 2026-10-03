import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/media/media_loader_service.dart';
import '../../../../design_system/design_system.dart';

class AppGlassImageCard extends StatefulWidget {
  const AppGlassImageCard({
    required this.wordId,
    required this.mediaLoader,
    this.semanticLabel,
    this.height = 168,
    super.key,
  });

  final String wordId;
  final MediaLoaderService mediaLoader;
  final String? semanticLabel;
  final double height;

  @override
  State<AppGlassImageCard> createState() => _AppGlassImageCardState();
}

class _AppGlassImageCardState extends State<AppGlassImageCard> {
  late Future<Uint8List?> _image;

  @override
  void initState() {
    super.initState();
    _image = widget.mediaLoader.loadWordImage(widget.wordId);
  }

  @override
  void didUpdateWidget(covariant AppGlassImageCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.wordId != widget.wordId ||
        oldWidget.mediaLoader != widget.mediaLoader) {
      _image = widget.mediaLoader.loadWordImage(widget.wordId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AppGlassCard(
      padding: EdgeInsets.zero,
      borderColor: dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: FutureBuilder<Uint8List?>(
          future: _image,
          builder: (context, snapshot) {
            final bytes = snapshot.data;
            if (snapshot.connectionState != ConnectionState.done) {
              return const _ImageShimmerSkeleton();
            }
            if (snapshot.hasError || bytes == null || bytes.isEmpty) {
              return const _ImagePlaceholder();
            }
            return Semantics(
              image: true,
              label: widget.semanticLabel ?? widget.wordId,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.memory(
                  bytes,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: dark ? AppColors.glassDarkGradient : AppColors.glassLightGradient,
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 36,
          color: dark ? AppColors.primaryDark : AppColors.primary,
        ),
      ),
    );
  }
}

class _ImageShimmerSkeleton extends StatefulWidget {
  const _ImageShimmerSkeleton();

  @override
  State<_ImageShimmerSkeleton> createState() => _ImageShimmerSkeletonState();
}

class _ImageShimmerSkeletonState extends State<_ImageShimmerSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final edge = dark ? AppColors.glassDarkEnd : AppColors.glassLightEnd;
    final highlight = dark ? AppColors.glassDarkStart : AppColors.glassLightStart;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final position = (_controller.value * 2.4) - 1.2;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(position - 1, 0),
              end: Alignment(position + 1, 0),
              colors: <Color>[edge, highlight, edge],
            ),
          ),
        );
      },
    );
  }
}
