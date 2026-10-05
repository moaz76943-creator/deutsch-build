import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'glass_card.dart';
import '../theme/app_design_system.dart';

class HomeProgressHero extends StatelessWidget {
  const HomeProgressHero({
    required this.levelLabel,
    required this.overallProgress,
    required this.streak,
    required this.masteredWords,
    required this.totalWords,
    required this.xp,
    this.greeting = 'مرحباً بك 👋',
    this.continueLabel = 'متابعة التعلّم الآن',
    this.onContinue,
    super.key,
  });

  final String levelLabel;
  final double overallProgress;
  final int streak;
  final int masteredWords;
  final int totalWords;
  final int xp;
  final String greeting;
  final String continueLabel;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final progress = overallProgress.clamp(0.0, 1.0).toDouble();
    final percent = (progress * 100).round();
    final learningSummary = totalWords <= 0
        ? 'خطوة قصيرة اليوم تحافظ على الاستمرارية.'
        : 'أتقنت $masteredWords من $totalWords كلمة في مسارك الحالي.';

    return Container(
      key: const Key('reference-home-hero'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFF111B35),
            Color(0xFF0B2748),
            Color(0xFF102E5E),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF38BDF8).withAlpha(38),
            blurRadius: 36,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: GlassCard(
        borderRadius: 28,
        blur: 22,
        opacity: 0.10,
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        greeting,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'أكمل من حيث توقفت',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.white,
                          fontSize: 28,
                          height: 1.15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        learningSummary,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.white.withAlpha(184),
                          fontSize: 12.5,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                CircularPercentIndicator(
                  key: const Key('home-circular-progress'),
                  radius: 47,
                  lineWidth: 9,
                  animation: true,
                  percent: progress,
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: const Color(0xFF38BDF8),
                  backgroundColor: Colors.white.withAlpha(24),
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        levelLabel,
                        key: const Key('home-level-badge'),
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '$percent%',
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: const Color(0xFF67E8F9),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _PrimaryLearningButton(
              label: continueLabel,
              onPressed: onContinue,
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: _HeaderMetric(
                    icon: FontAwesomeIcons.fire,
                    iconColor: const Color(0xFFF97316),
                    value: streak.toString(),
                    label: 'يوم متتالي',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _HeaderMetric(
                    icon: FontAwesomeIcons.solidStar,
                    iconColor: const Color(0xFFEAB308),
                    value: xp.toString(),
                    label: 'نقطة XP',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _HeaderMetric(
                    icon: FontAwesomeIcons.graduationCap,
                    iconColor: const Color(0xFF38BDF8),
                    value: masteredWords.toString(),
                    label: 'كلمة متقنة',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 420.ms)
        .slideY(begin: -0.04, end: 0, duration: 420.ms);
  }
}

class _PrimaryLearningButton extends StatelessWidget {
  const _PrimaryLearningButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFF2563EB),
            Color(0xFF0284C7),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF38BDF8).withAlpha(72),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const FaIcon(
          FontAwesomeIcons.play,
          size: 15,
          color: Colors.white,
        ),
        label: Text(
          label,
          style: TextStyle(
                          fontFamily: 'Cairo',
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 180.ms, duration: 300.ms)
        .scale(
          begin: const Offset(0.98, 0.98),
          end: const Offset(1, 1),
          duration: 300.ms,
        );
  }
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final FaIconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 18,
      blur: 16,
      opacity: 0.10,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FaIcon(icon, size: 17, color: iconColor),
          const SizedBox(height: 4),
          Text(
            value,
            textDirection: TextDirection.ltr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                          fontFamily: 'Cairo',
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                          fontFamily: 'Cairo',
              color: Colors.white.withAlpha(170),
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
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
  Widget build(BuildContext context) {
    final actions = <_QuickActionSpec>[
      _QuickActionSpec(
        key: const Key('daily-lessons-card'),
        icon: FontAwesomeIcons.bookOpen,
        title: 'دروس اليوم',
        subtitle: 'تابع مسارك',
        color: const Color(0xFF38BDF8),
        onTap: onDailyLessons,
      ),
      _QuickActionSpec(
        key: const Key('ai-conversation-card'),
        icon: FontAwesomeIcons.comments,
        title: 'محادثة AI',
        subtitle: 'تحدث بثقة',
        color: const Color(0xFF22C55E),
        onTap: onAiConversation,
      ),
      _QuickActionSpec(
        key: const Key('quick-practice-card'),
        icon: FontAwesomeIcons.bolt,
        title: 'تدريب سريع',
        subtitle: 'جلسة مركزة',
        color: const Color(0xFF8B5CF6),
        onTap: onQuickPractice,
      ),
      _QuickActionSpec(
        key: const Key('assessment-card'),
        icon: FontAwesomeIcons.chartLine,
        title: 'اختبار المستوى',
        subtitle: 'قِس تقدمك',
        color: const Color(0xFFF59E0B),
        onTap: onAssessment,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionHeading(
          title: 'أدوات الممارسة اليومية',
          icon: FontAwesomeIcons.bolt,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 106,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: actions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _QuickActionCard(actions[index]),
          ),
        )
            .animate()
            .fadeIn(delay: 160.ms, duration: 350.ms)
            .slideX(begin: 0.05, end: 0),
        const SizedBox(height: 26),
        const _SectionHeading(
          title: 'درسك القادم',
          icon: FontAwesomeIcons.graduationCap,
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onDailyLessons,
          behavior: HitTestBehavior.opaque,
          child: GlassCard(
            borderRadius: 24,
            blur: 18,
            opacity: 0.10,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withAlpha(28),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFF38BDF8).withAlpha(66),
                    ),
                  ),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.city,
                      color: Color(0xFF38BDF8),
                      size: 23,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'تابع مسار التعلم',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'افتح النشاط التالي المقترح حسب تقدمك الحالي',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.white.withAlpha(158),
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white54,
                  size: 16,
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(delay: 260.ms, duration: 350.ms)
            .slideX(begin: 0.05, end: 0),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.icon,
  });

  final String title;
  final FaIconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        FaIcon(icon, size: 16, color: const Color(0xFF38BDF8)),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
                          fontFamily: 'Cairo',
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _QuickActionSpec {
  const _QuickActionSpec({
    required this.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final Key key;
  final FaIconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard(this.spec);

  final _QuickActionSpec spec;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: spec.key,
      width: 148,
      child: GestureDetector(
        onTap: spec.onTap,
        behavior: HitTestBehavior.opaque,
        child: GlassCard(
          borderRadius: 22,
          blur: 16,
          opacity: 0.09,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: spec.color.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FaIcon(spec.icon, size: 17, color: spec.color),
              ),
              const SizedBox(height: 8),
              Text(
                spec.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                          fontFamily: 'Cairo',
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                spec.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                          fontFamily: 'Cairo',
                  color: Colors.white.withAlpha(145),
                  fontSize: 9.5,
                ),
              ),
            ],
          ),
        ),
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
      const _TrackSpec(
        keyName: 'recall',
        label: 'التعرّف',
        icon: FontAwesomeIcons.brain,
        color: AppPalette.primary,
      ),
      const _TrackSpec(
        keyName: 'listening',
        label: 'الاستماع',
        icon: FontAwesomeIcons.headphones,
        color: AppPalette.secondary,
      ),
      const _TrackSpec(
        keyName: 'production',
        label: 'الإنتاج',
        icon: FontAwesomeIcons.microphone,
        color: AppPalette.achievement,
      ),
      const _TrackSpec(
        keyName: 'transfer',
        label: 'النقل',
        icon: FontAwesomeIcons.arrowRightArrowLeft,
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
        final score =
            (skillScores[track.keyName] ?? 0).clamp(0.0, 1.0).toDouble();
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
    final color = primary ? const Color(0xFF38BDF8) : const Color(0xFF8B5CF6);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor =
        isDark ? Colors.white : Theme.of(context).colorScheme.onSurface;
    final subtitleColor = isDark
        ? Colors.white.withAlpha(148)
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: GlassCard(
        borderRadius: 22,
        blur: 16,
        opacity: primary ? 0.13 : 0.08,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        child: Row(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withAlpha(28),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                          fontFamily: 'Cairo',
                      color: titleColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                          fontFamily: 'Cairo',
                      color: subtitleColor,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white38 : Colors.black38,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _LearningTrackCard extends StatelessWidget {
  const _LearningTrackCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.progress,
  });

  final String label;
  final FaIconData icon;
  final Color color;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final value = progress.clamp(0.0, 1.0).toDouble();
    final percent = (value * 100).round();
    final labelColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;

    return GlassCard(
      borderRadius: 22,
      blur: 14,
      opacity: 0.08,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              FaIcon(icon, size: 18, color: color),
              const Spacer(),
              Text(
                '$percent%',
                textDirection: TextDirection.ltr,
                style: TextStyle(
                          fontFamily: 'Cairo',
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            label,
            style: TextStyle(
                          fontFamily: 'Cairo',
              color: labelColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: color.withAlpha(24),
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
  final FaIconData icon;
  final Color color;
}

class ReferenceFloatingNavigationBar extends StatelessWidget {
  const ReferenceFloatingNavigationBar({
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final darkSurface =
        selectedIndex == 0 || Theme.of(context).brightness == Brightness.dark;
    const destinations = <_NavDestination>[
      _NavDestination(FontAwesomeIcons.house, 'الرئيسية'),
      _NavDestination(FontAwesomeIcons.bookOpen, 'الدروس'),
      _NavDestination(FontAwesomeIcons.comments, 'محادثة'),
      _NavDestination(FontAwesomeIcons.chartSimple, 'التقدم'),
      _NavDestination(FontAwesomeIcons.bars, 'المزيد'),
    ];

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: GlassCard(
        key: const Key('main-navigation-bar'),
        borderRadius: 26,
        blur: 22,
        opacity: 0.18,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List<Widget>.generate(destinations.length, (index) {
            final destination = destinations[index];
            final selected = index == selectedIndex;
            final color = selected
                ? const Color(0xFF38BDF8)
                : darkSurface
                    ? Colors.white54
                    : const Color(0xFF64748B);

            return Expanded(
              child: Semantics(
                button: true,
                selected: selected,
                label: destination.label,
                child: InkWell(
                  onTap: () => onSelected(index),
                  borderRadius: BorderRadius.circular(18),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF38BDF8).withAlpha(22)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        FaIcon(destination.icon, size: 17, color: color),
                        const SizedBox(height: 4),
                        Text(
                          destination.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                          fontFamily: 'Cairo',
                            fontSize: 9.5,
                            fontWeight:
                                selected ? FontWeight.w800 : FontWeight.w500,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination(this.icon, this.label);

  final FaIconData icon;
  final String label;
}
