import '../design_system/design_system.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إحصائيات التقدم ومعدل الحفظ'),
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
                gradient: AppGradients.heroSunset,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('معدل الاسترجاع والذاكرة الدائمة', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('88.4%', style: AppTypography.display.copyWith(color: Colors.white, fontSize: 32)),
                        const Icon(Icons.psychology_rounded, color: Colors.white, size: 44),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: 0.884,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: AppBaseGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Icon(Icons.bolt_rounded, color: Color(0xFFF39C6B), size: 28),
                          const SizedBox(height: 8),
                          Text('142', style: AppTypography.title.copyWith(color: Colors.white, fontSize: 22)),
                          const Text('كلمة متقنة بالـ SRS', style: TextStyle(color: Colors.white60, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppBaseGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Icon(Icons.timer_rounded, color: Color(0xFF10B981), size: 28),
                          const SizedBox(height: 8),
                          Text('18.5 س', style: AppTypography.title.copyWith(color: Colors.white, fontSize: 22)),
                          const Text('إجمالي وقت التعلم', style: TextStyle(color: Colors.white60, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('النشاط الأسبوعي للمراجعة', style: AppTypography.title.copyWith(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 10),
              AppBaseGlassCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _bar('سبت', 0.4),
                    _bar('أحد', 0.7),
                    _bar('اثنين', 0.9),
                    _bar('ثلاثاء', 0.5),
                    _bar('أربعاء', 0.85),
                    _bar('خميس', 1.0, isHighest: true),
                    _bar('جمعة', 0.3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bar(String day, double ratio, {bool isHighest = false}) {
    return Column(
      children: <Widget>[
        Container(
          width: 14,
          height: 100 * ratio,
          decoration: BoxDecoration(
            color: isHighest ? const Color(0xFF38BDF8) : Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: TextStyle(color: isHighest ? const Color(0xFF38BDF8) : Colors.white60, fontSize: 11)),
      ],
    );
  }
}
