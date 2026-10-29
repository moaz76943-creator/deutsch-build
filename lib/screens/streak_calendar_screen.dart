import '../design_system/design_system.dart';

class StreakCalendarScreen extends StatelessWidget {
  const StreakCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سلسلة الالتزام اليومي (Streak)'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: <Widget>[
              AppBaseGlassCard(
                gradient: AppGradients.purpleCard,
                child: Column(
                  children: <Widget>[
                    const Icon(Icons.local_fire_department_rounded, color: Color(0xFFF39C6B), size: 64),
                    const SizedBox(height: 12),
                    Text('5 أيام متتالية!', style: AppTypography.display.copyWith(color: Colors.white, fontSize: 26)),
                    const SizedBox(height: 6),
                    const Text('حافظ على استمرارية الدراسة لتفادي خسارة التقدم', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppBaseGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('تقويم شهر أكتوبر 2026', style: AppTypography.title.copyWith(color: Colors.white, fontSize: 16)),
                        const Icon(Icons.calendar_month_rounded, color: Color(0xFF38BDF8)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: 31,
                      itemBuilder: (context, index) {
                        final day = index + 1;
                        final isCompleted = day <= 5;
                        final isToday = day == 5;
                        return Container(
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? (isToday ? const Color(0xFFF39C6B) : const Color(0xFF2563EB).withValues(alpha: 0.6))
                                : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: isToday ? Border.all(color: Colors.white, width: 1.5) : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$day',
                            style: TextStyle(
                              color: isCompleted ? Colors.white : Colors.white30,
                              fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppBaseGlassCard(
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.ac_unit_rounded, color: Color(0xFF38BDF8), size: 32),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('تجميد السلسلة (Streak Freeze)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('يحمي سلسلتك في حال فاتك التعلم ليوم واحد', style: TextStyle(color: Colors.white60, fontSize: 11)),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF38BDF8)),
                      child: const Text('مفعل (2)', style: TextStyle(color: Color(0xFF0B1F4D))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
