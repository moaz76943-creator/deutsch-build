import 'package:flutter/material.dart';

class HomeWelcomeSurface extends StatelessWidget {
  const HomeWelcomeSurface({
    required this.hasAttempts,
    super.key,
  });

  final bool hasAttempts;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const Key('home-welcome-surface'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primaryContainer, scheme.surface],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(
              Icons.auto_awesome_outlined,
              color: scheme.onPrimary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('مرحبًا', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  hasAttempts
                      ? 'خطة اليوم جاهزة بناءً على ما تعلمته وما يحتاج مراجعة.'
                      : 'ابدأ بخطوة قصيرة، وسنبني مسارك من أدائك الحقيقي.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class FeatureNavigationCard extends StatelessWidget {
  const FeatureNavigationCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.primary = false,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: primary ? scheme.primaryContainer : null,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: primary
                ? scheme.primary.withValues(alpha: 0.12)
                : scheme.secondaryContainer,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            color: primary ? scheme.primary : scheme.onSecondaryContainer,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.chevron_left_rounded),
        onTap: onTap,
      ),
    );
  }
}
