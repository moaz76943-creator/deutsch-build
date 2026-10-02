import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_design_system.dart';

class HomeProgressHero extends StatelessWidget {
  const HomeProgressHero({
    required this.levelLabel,
    required this.overallProgress,
    required this.streak,
    required this.masteredWords,
    required this.totalWords,
    required this.xp,
    super.key,
  });

  final String levelLabel;
  final double overallProgress;
  final int streak;
  final int masteredWords;
  final int totalWords;
  final int xp;

  @override
  Widget build(BuildContext context) {
    final value = overallProgress.clamp(0.0, 1.0).toDouble();
    final pct = (value * 100).round();

    return Container(
      key: const Key('reference-home-hero'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFF071E4B),
            Color(0xFF123F91),
            Color(0xFF087D79),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppPalette.primary.withValues(alpha: 0.22),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Hallo Salim! 👋',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'واصل التعلم وحافظ على تقدمك',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.80),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _LevelBadge(label: levelLabel),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'التقدم العام',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$pct%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 72,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  CircularProgressIndicator(
                    key: const Key('home-circular-progress'),
                    value: value,
                    strokeWidth: 7,
                    strokeCap: StrokeCap.round,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF53F1B8)),
                  ),
                  Text('\$pct%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Expanded(
                child: _HeroMetric(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: const Color(0xFFFF7A21),
                  value: '$streak',
                  label: 'يوم متتالي',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HeroMetric(
                  icon: Icons.auto_stories_rounded,
                  iconColor: AppPalette.mastery,
                  value: totalWords > 0
                      ? '$masteredWords/$totalWords'
                      : '$masteredWords',
                  label: 'كلمة مكتسبة',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HeroMetric(
                  icon: Icons.bolt_rounded,
                  iconColor: AppPalette.xp,
                  value: '$xp',
                  label: 'XP',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LearningTrackGrid extends StatelessWidget {
  const LearningTrackGrid({
    required this.skillScores,
    super.key,
  });

  final Map<String, double> skillScores;

  @override
  Widget build(BuildContext context) {
    final tracks = <_TrackSpec>[
      _TrackSpec(
        keyName: 'recall',
        label: 'التعرّف',
        icon: Icons.visibility_outlined,
        color: AppPalette.primary,
      ),
      _TrackSpec(
        keyName: 'listening',
        label: 'الاستماع',
        icon: Icons.headphones_rounded,
        color: AppPalette.secondary,
      ),
      _TrackSpec(
        keyName: 'production',
        label: 'الإنتاج',
        icon: Icons.edit_note_rounded,
        color: AppPalette.achievement,
      ),
      _TrackSpec(
        keyName: 'transfer',
        label: 'النقل',
        icon: Icons.compare_arrows_rounded,
        color: AppPalette.mastery,
      ),
    ];

    return GridView.builder(
      key: const Key('learning-track-grid'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tracks.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.55,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final track = tracks[index];
        final score = (skillScores[track.keyName] ?? 0).clamp(0.0, 1.0).toDouble();
        return _LearningTrackCard(
          label: track.label,
          icon: track.icon,
          color: track.color,
          progress: score,
        );
      },
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

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    key: const Key('home-level-badge'),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
    ),
    child: Text(
      label,
      textDirection: TextDirection.ltr,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
    ),
    child: Column(
      children: <Widget>[
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 10,
          ),
        ),
      ],
    ),
  );
}

class _LearningTrackCard extends StatelessWidget {
  const _LearningTrackCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.progress,
  });

  final String label;
  final IconData icon;
  final Color color;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: color.withValues(alpha: 0.20),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const Spacer(),
              Text(
                '$pct%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: color.withValues(alpha: 0.10),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackSpec {
  const _TrackSpec({
    required this.keyName,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String keyName;
  final String label;
  final IconData icon;
  final Color color;
}

class ReferenceHomeActions extends StatelessWidget {
  const ReferenceHomeActions({
    required this.onDailyLessons,
    required this.onAiConversation,
    required this.onQuickPractice,
    required this.onAssessment,
    super.key,
  });
  final VoidCallback onDailyLessons;
  final VoidCallback onAiConversation;
  final VoidCallback onQuickPractice;
  final VoidCallback onAssessment;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _ReferenceActionCard(key: const Key('daily-lessons-card'), title: 'دروس اليوم', subtitle: '5 تمارين في انتظارك', icon: Icons.menu_book_rounded, colors: const [Color(0xFF0759D9), Color(0xFF1296F3)], onTap: onDailyLessons),
      const SizedBox(height: 11),
      _ReferenceActionCard(key: const Key('ai-conversation-card'), title: 'محادثة بالذكاء الاصطناعي', subtitle: 'تحدث وتعلم بنطق طبيعي', icon: Icons.chat_bubble_rounded, colors: const [Color(0xFF6424E8), Color(0xFFB319E7)], onTap: onAiConversation),
      const SizedBox(height: 11),
      Row(children: [
        Expanded(child: _ReferenceActionCard(key: const Key('quick-practice-card'), title: 'التدريب السريع', subtitle: '15 دقيقة', icon: Icons.edit_rounded, compact: true, colors: const [Color(0xFF087D58), Color(0xFF17B873)], onTap: onQuickPractice)),
        const SizedBox(width: 10),
        Expanded(child: _ReferenceActionCard(key: const Key('assessment-card'), title: 'الاختبارات', subtitle: 'اختبر مستواك', icon: Icons.fact_check_rounded, compact: true, colors: const [Color(0xFFC51D55), Color(0xFFF04475)], onTap: onAssessment)),
      ]),
    ],
  );
}

class _ReferenceActionCard extends StatelessWidget {
  const _ReferenceActionCard({required this.title, required this.subtitle, required this.icon, required this.colors, required this.onTap, this.compact = false, super.key});
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Ink(
        height: compact ? 112 : 88,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(colors: colors, begin: Alignment.topRight, end: Alignment.bottomLeft),
          border: Border.all(color: Colors.white24),
          boxShadow: [BoxShadow(color: colors.first.withValues(alpha: .24), blurRadius: 20, offset: const Offset(0, 9))],
        ),
        child: Row(children: [
          Container(width: 46, height: 46, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .18), borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: Colors.white)),
          const SizedBox(width: 10),
          Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, maxLines: 2, style: TextStyle(color: Colors.white, fontSize: compact ? 15 : 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withValues(alpha: .84), fontSize: 11)),
          ])),
          if (!compact) const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
        ]),
      ),
    ),
  );
}

class ReferenceFloatingNavigationBar extends StatelessWidget {
  const ReferenceFloatingNavigationBar({required this.selectedIndex, required this.onSelected, super.key});
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: .90),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: .72)),
            boxShadow: const [BoxShadow(color: Color(0x1F082B64), blurRadius: 26, offset: Offset(0, 10))],
          ),
          child: NavigationBar(
            key: const Key('main-navigation-bar'),
            selectedIndex: selectedIndex,
            onDestinationSelected: onSelected,
            backgroundColor: Colors.transparent,
            indicatorColor: const Color(0xFFDDEBFF),
            elevation: 0,
            height: 68,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF0866D9)), label: 'الرئيسية'),
              NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book_rounded, color: Color(0xFF0866D9)), label: 'الدروس'),
              NavigationDestination(icon: Icon(Icons.forum_outlined), selectedIcon: Icon(Icons.forum_rounded, color: Color(0xFF0866D9)), label: 'محادثة'),
              NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart_rounded, color: Color(0xFF0866D9)), label: 'التقدم'),
              NavigationDestination(icon: Icon(Icons.more_horiz_rounded), selectedIcon: Icon(Icons.more_horiz_rounded, color: Color(0xFF0866D9)), label: 'المزيد'),
            ],
          ),
        ),
      ),
    ),
  );
}
