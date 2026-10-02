import 'package:flutter/material.dart';

import '../theme/app_design_system.dart';

Color articleBadgeColor(String article) {
  switch (article.trim().toLowerCase()) {
    case 'der':
      return AppPalette.articleDer;
    case 'die':
      return AppPalette.articleDie;
    case 'das':
      return AppPalette.articleDas;
    default:
      return AppPalette.articleOther;
  }
}

class ArticleBadge extends StatelessWidget {
  const ArticleBadge({
    required this.article,
    this.prominent = false,
    this.compact = false,
    this.margin,
    super.key,
  });

  final String article;
  final bool prominent;
  final bool compact;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final value = article.trim().toLowerCase();
    if (value.isEmpty) return const SizedBox.shrink();

    final color = articleBadgeColor(value);
    final horizontal = prominent ? 14.0 : (compact ? 7.0 : 9.0);
    final vertical = prominent ? 6.0 : (compact ? 3.0 : 4.0);
    final fontSize = prominent ? 18.0 : (compact ? 11.0 : 12.0);

    return Semantics(
      label: 'أداة التعريف $value',
      child: Container(
        key: Key('article-badge-$value'),
        margin: margin,
        padding: EdgeInsets.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(prominent ? 11 : 8),
          border: Border.all(
            color: color.withValues(alpha: 0.48),
            width: prominent ? 1.4 : 1,
          ),
        ),
        child: Text(
          value,
          textDirection: TextDirection.ltr,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ),
    );
  }
}
