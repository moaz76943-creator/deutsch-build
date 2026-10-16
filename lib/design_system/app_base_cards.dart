import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_design_tokens.dart';
import 'app_gradients.dart';
import 'app_typography.dart';

class AppBaseGlassCard extends StatelessWidget {
  const AppBaseGlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppDesignTokens.spaceM),
    this.borderRadius = 26,
    this.gradient,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: gradient ??
                LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Colors.white.withValues(alpha: 0.20),
                    Colors.white.withValues(alpha: 0.08),
                  ],
                ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1.1,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 28,
                spreadRadius: 1,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.04),
                blurRadius: 10,
                spreadRadius: -2,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap == null) return body;
    return InkWell(
      borderRadius: BorderRadius.circular(borderRadius),
      onTap: onTap,
      child: body,
    );
  }
}

class AppFeatureCard extends StatelessWidget {
  const AppFeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.gradient = AppGradients.blueCard,
    this.trailing,
    this.onTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppBaseGlassCard(
      onTap: onTap,
      gradient: gradient,
      child: Row(
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: AppTypography.title.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class ArticleBadge extends StatelessWidget {
  const ArticleBadge({
    required this.article,
    required this.label,
    super.key,
  });

  final String article;
  final String label;

  Color get _color {
    switch (article.trim().toLowerCase()) {
      case 'der':
        return const Color(0xFF2563EB);
      case 'die':
        return const Color(0xFFEC4899);
      case 'das':
        return const Color(0xFF14B8A6);
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _color.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            article,
            style: AppTypography.label.copyWith(
              color: _color,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.label.copyWith(
              color: _color.withValues(alpha: 0.88),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
