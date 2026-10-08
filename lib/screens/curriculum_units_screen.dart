
import '../design_system/design_system.dart';

class CurriculumUnitsScreen extends StatelessWidget {
  const CurriculumUnitsScreen({super.key});

  final units = const [
    {'title': 'الوحدة 1: التحيات والتعارف', 'lessons': '4 دروس • 28 مفردة', 'isUnlocked': true, 'progress': 0.75},
    {'title': 'الوحدة 2: الأرقام وأدوات التعريف', 'lessons': '5 دروس • 42 مفردة', 'isUnlocked': true, 'progress': 0.20},
    {'title': 'الوحدة 3: العائلة والمنزل', 'lessons': '6 دروس • 50 مفردة', 'isUnlocked': false, 'progress': 0.0},
    {'title': 'الوحدة 4: التسوق والطعام', 'lessons': '5 دروس • 35 مفردة', 'isUnlocked': false, 'progress': 0.0},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
      child: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 96),
          itemCount: units.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final u = units[index];
            final unlocked = u['isUnlocked'] as bool;
            final progress = u['progress'] as double;

            return AppBaseGlassCard(
              gradient: unlocked ? null : LinearGradient(colors: [Colors.black.withValues(alpha: 0.4), Colors.black.withValues(alpha: 0.2)]),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: unlocked ? const Color(0xFF2F6BFF).withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      unlocked ? Icons.check_circle_outline_rounded : Icons.lock_outline_rounded,
                      color: unlocked ? const Color(0xFF60A5FA) : Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          u['title'] as String,
                          style: AppTypography.title.copyWith(
                            color: unlocked ? Colors.white : Colors.white.withValues(alpha: 0.5),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          u['lessons'] as String,
                          style: AppTypography.body.copyWith(
                            color: unlocked ? Colors.white.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.35),
                            fontSize: 12,
                          ),
                        ),
                        if (unlocked) ...<Widget>[
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white.withValues(alpha: 0.15),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
