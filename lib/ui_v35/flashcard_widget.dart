import 'dart:math';

import 'package:flutter/material.dart';

class FlashcardWidget extends StatefulWidget {
  final String frontText;
  final String backText;
  final String? article;
  final VoidCallback onAudio;
  final Widget? trailing;

  const FlashcardWidget({
    super.key,
    required this.frontText,
    required this.backText,
    this.article,
    required this.onAudio,
    this.trailing,
  });

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }

  Color _getArticleColor() {
    switch (widget.article?.toLowerCase() ?? "") {
      case 'der':
        return const Color(0xFF2563EB); // Slate Blue
      case 'die':
        return const Color(0xFFE11D48); // Soft Crimson
      case 'das':
        return const Color(0xFF0D9488); // Deep Teal
      case 'plural':
        return const Color(0xFF7C3AED); // Muted Violet
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * pi;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          final isFrontVisible = angle <= pi / 2;

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: isFrontVisible
                ? _buildFront()
                : Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _buildBack(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    final articleColor = widget.article != null && widget.article!.isNotEmpty
        ? _getArticleColor()
        : Colors.transparent;

    return Card(
      color: Colors.blue.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: articleColor.withValues(alpha: 0.5), width: 2),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.frontText,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (widget.article != null && widget.article!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: articleColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.article ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: widget.trailing ?? const SizedBox.shrink(),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.volume_up),
              onPressed: () {
                widget.onAudio();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return Card(
      color: Colors.green.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            widget.backText,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
