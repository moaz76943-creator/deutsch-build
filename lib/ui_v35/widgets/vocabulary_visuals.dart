import 'package:flutter/material.dart';

import '../shared/article_badge.dart';

class VocabularyWordHeader extends StatelessWidget {
  const VocabularyWordHeader({
    required this.article,
    required this.german,
    required this.arabic,
    required this.topic,
    required this.onSpeak,
    this.phonetic,
    this.isFavorite = false,
    this.onToggleFavorite,
    super.key,
  });

  final String article;
  final String german;
  final String arabic;
  final String topic;
  final String? phonetic;
  final bool isFavorite;
  final VoidCallback onSpeak;
  final VoidCallback? onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hint = phonetic?.trim() ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  if (article.trim().isNotEmpty) ArticleBadge(article: article),
                  Text(
                    german,
                    textDirection: TextDirection.ltr,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                  ),
                ],
              ),
              if (hint.isNotEmpty) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  hint,
                  textDirection: TextDirection.ltr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.tertiary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
              const SizedBox(height: 5),
              Text(
                arabic,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (topic.trim().isNotEmpty) ...<Widget>[
                const SizedBox(height: 5),
                Text(
                  topic,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          children: <Widget>[
            _VocabularyActionButton(
              tooltip: 'استماع',
              icon: Icons.volume_up_rounded,
              color: scheme.primary,
              onPressed: onSpeak,
            ),
            if (onToggleFavorite != null) ...<Widget>[
              const SizedBox(height: 7),
              _VocabularyActionButton(
                tooltip: isFavorite ? 'إزالة من المفضلة' : 'إضافة للمفضلة',
                icon: isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isFavorite ? const Color(0xFFD94662) : scheme.secondary,
                onPressed: onToggleFavorite!,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class VocabularyGridCard extends StatelessWidget {
  const VocabularyGridCard({
    required this.article,
    required this.german,
    required this.arabic,
    required this.topic,
    required this.isFavorite,
    required this.onSpeak,
    required this.onToggleFavorite,
    this.phonetic,
    super.key,
  });

  final String article;
  final String german;
  final String arabic;
  final String topic;
  final String? phonetic;
  final bool isFavorite;
  final VoidCallback onSpeak;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final articleColor = articleBadgeColor(article);
    final hint = phonetic?.trim() ?? '';

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: article.trim().isEmpty
              ? scheme.outlineVariant.withValues(alpha: 0.55)
              : articleColor.withValues(alpha: 0.28),
        ),
      ),
      child: InkWell(
        onTap: onSpeak,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  if (article.trim().isNotEmpty)
                    ArticleBadge(article: article, compact: true),
                  const Spacer(),
                  IconButton(
                    tooltip: isFavorite ? 'إزالة من المفضلة' : 'إضافة للمفضلة',
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 20,
                      color: isFavorite
                          ? const Color(0xFFD94662)
                          : scheme.onSurfaceVariant,
                    ),
                    onPressed: onToggleFavorite,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                german,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.ltr,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              if (hint.isNotEmpty) ...<Widget>[
                const SizedBox(height: 3),
                Text(
                  hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.ltr,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.tertiary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
              const SizedBox(height: 5),
              Text(
                arabic,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      topic,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _VocabularyActionButton(
                    tooltip: 'استماع',
                    icon: Icons.volume_up_rounded,
                    color: scheme.primary,
                    onPressed: onSpeak,
                    compact: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VocabularyActionButton extends StatelessWidget {
  const _VocabularyActionButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.compact = false,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: Material(
          color: color.withValues(alpha: 0.11),
          borderRadius: BorderRadius.circular(compact ? 12 : 14),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(compact ? 12 : 14),
            child: SizedBox(
              width: compact ? 34 : 40,
              height: compact ? 34 : 40,
              child: Icon(icon, size: compact ? 18 : 20, color: color),
            ),
          ),
        ),
      );
}
