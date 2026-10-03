import 'package:flutter/material.dart';

import '../../core/text/directional_text.dart';
import '../../features/gamification/domain/gamification_models.dart';
import '../shared/text/bidi_text.dart';

class GamificationSummaryGrid extends StatelessWidget {
  const GamificationSummaryGrid({super.key, required this.snapshot});

  final GamificationSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final profile = snapshot.profile;
    final xp = profile.xpProgress;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.bolt_outlined,
                label: 'إجمالي الخبرة',
                value: '${xp.totalXp} XP',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                icon: Icons.local_fire_department_outlined,
                label: 'السلسلة الحالية',
                value: '${profile.currentStreak}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.stairs_outlined,
                label: 'المستوى',
                value: '${xp.level}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                icon: Icons.workspace_premium_outlined,
                label: 'الشارات',
                value: '${snapshot.unlocked.length}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'التقدم نحو المستوى التالي',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(value: xp.progressToNextLevel),
                const SizedBox(height: 8),
                BidiText(
                  DirectionalText.forLanguage(
                    '${xp.totalXp} / ${xp.nextLevelXp} XP',
                    languageCode: 'en',
                    semanticRole: LinguisticSemanticRole.number,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class GamificationNextMilestoneCard extends StatelessWidget {
  const GamificationNextMilestoneCard({super.key, required this.snapshot});

  final GamificationSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final badge = snapshot.nextMilestone;
    if (badge == null) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.verified_outlined),
          title: Text('كل المعالم الحالية مكتملة'),
          subtitle: Text('سيتم إظهار معالم جديدة عند إضافتها إلى المحرك.'),
        ),
      );
    }

    final profile = snapshot.profile;
    final threshold = badge.xpThreshold ?? badge.streakThreshold ?? 1;
    final current =
        badge.xpThreshold != null ? profile.totalXp : profile.currentStreak;
    final progress = (current / threshold).clamp(0.0, 1.0).toDouble();
    final unit = badge.xpThreshold != null ? 'XP' : 'يوم';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.flag_outlined),
                SizedBox(width: 8),
                Text(
                  'المعلم التالي',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              badge.titleAr,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(badge.descriptionAr),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 8),
            BidiText(
              DirectionalText.forLanguage(
                '$current / $threshold $unit',
                languageCode: unit == 'XP' ? 'en' : 'ar',
                semanticRole: LinguisticSemanticRole.number,
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class GamificationBadgeList extends StatelessWidget {
  const GamificationBadgeList({super.key, required this.snapshot});

  final GamificationSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final unlocked = snapshot.unlockedBadgeIds;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'الشارات',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            for (final badge in snapshot.badges)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  unlocked.contains(badge.id)
                      ? Icons.workspace_premium
                      : Icons.lock_outline,
                ),
                title: Text(
                  badge.titleAr,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(badge.descriptionAr),
                trailing: unlocked.contains(badge.id)
                    ? const Icon(Icons.check_circle_outline)
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}

class GamificationClockWarning extends StatelessWidget {
  const GamificationClockWarning({super.key});

  @override
  Widget build(BuildContext context) => const Card(
        child: ListTile(
          leading: Icon(Icons.schedule_outlined),
          title: Text(
            'تم رصد رجوع غير طبيعي في ساعة الجهاز',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          subtitle: Text(
            'تم إيقاف مكافأة الحدث المشبوه بدل زيادة XP أو السلسلة. '
            'المراجعات التعليمية نفسها لا تُحذف.',
          ),
        ),
      );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          child: Column(
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              BidiText(
                DirectionalText.forLanguage(
                  value,
                  languageCode: 'en',
                  semanticRole: LinguisticSemanticRole.number,
                ),
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      );
}
