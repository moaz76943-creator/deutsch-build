import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import '../design_system/app_cognitive_tokens.dart';
import '../core/streak_engine.dart';

class StreakCalendarScreen extends StatefulWidget {
  final String languageCode;
  const StreakCalendarScreen({super.key, this.languageCode = 'de'});

  @override
  State<StreakCalendarScreen> createState() => _StreakCalendarScreenState();
}

class _StreakCalendarScreenState extends State<StreakCalendarScreen> {
  int _currentStreak = 0;
  int _freezesAvailable = 2;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStreakStats();
  }

  Future<void> _loadStreakStats() async {
    final streak = await StreakEngine.getCurrentStreak();
    final freezes = await StreakEngine.getFreezesAvailable();
    if (mounted) {
      setState(() {
        _currentStreak = streak;
        _freezesAvailable = freezes;
        _isLoading = false;
      });
    }
  }

  void _triggerShieldHaptic() {
    AppCognitiveTokens.triggerSuccessHaptic();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'درع التجميد نشط لحماية مسار تعلّمك (${widget.languageCode.toUpperCase()}) 🛡️'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInCurrentMonth = DateTime(now.year, now.month + 1, 0).day;
    final currentDay = now.day;

    final monthNames = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    final currentMonthTitle = '${monthNames[now.month - 1]} ${now.year}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('السلسلة اليومية (Streak)'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: <Widget>[
                    AppBaseGlassCard(
                      gradient: AppGradients.purpleCard,
                      child: Column(
                        children: <Widget>[
                          const Icon(
                            Icons.local_fire_department_rounded,
                            color: Color(0xFFF39C6B),
                            size: 64,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '$_currentStreak أيام متتالية!',
                            style: AppTypography.display.copyWith(
                              color: Colors.white,
                              fontSize: 26,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'استمر في الدراسة يومياً لترسيخ التعلم',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12),
                          ),
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
                              Expanded(
                          child: Text(
                            currentMonthTitle,
                            style: AppTypography.title.copyWith(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                              const Icon(
                                Icons.calendar_month_rounded,
                                color: Color(0xFF38BDF8),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                            ),
                            itemCount: daysInCurrentMonth,
                            itemBuilder: (context, index) {
                              final day = index + 1;
                              final isToday = day == currentDay;
                              final isCompleted = day <= currentDay &&
                                  day > (currentDay - _currentStreak);

                              return Container(
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? (isToday
                                          ? const Color(0xFFF39C6B)
                                          : const Color(0xFF2563EB)
                                              .withValues(alpha: 0.6))
                                      : Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(10),
                                  border: isToday
                                      ? Border.all(
                                          color: Colors.white,
                                          width: 1.5,
                                        )
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '$day',
                                  style: TextStyle(
                                    color: isCompleted
                                        ? Colors.white
                                        : Colors.white30,
                                    fontWeight: isCompleted
                                        ? FontWeight.bold
                                        : FontWeight.normal,
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
                          const Icon(
                            Icons.ac_unit_rounded,
                            color: Color(0xFF38BDF8),
                            size: 32,
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'درع تجميد السلسلة (Streak Freeze)',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'يحمي سلسلتك في حال فاتك يوم واحد',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FilledButton(
                            onPressed: _triggerShieldHaptic,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF38BDF8),
                            ),
                            child: Text(
                              'تفعيل ($_freezesAvailable)',
                              style: const TextStyle(
                                color: Color(0xFF0B1F4D),
                              ),
                            ),
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
