import 'package:flutter/material.dart';
import '../../design_system/design_system.dart';
import 'accessible_multilingual_text.dart';

class LexiconRichDetails extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const LexiconRichDetails({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (content.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.white70),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.caption.copyWith(color: Colors.white54),
                ),
                const SizedBox(height: 4),
                AccessibleMultilingualText(
                  content,
                  style: AppTypography.body.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
