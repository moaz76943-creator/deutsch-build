import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

class DailyChallengesScreen extends StatefulWidget {
  const DailyChallengesScreen({super.key});

  @override
  State<DailyChallengesScreen> createState() => _DailyChallengesScreenState();
}

class _DailyChallengesScreenState extends State<DailyChallengesScreen> {
  final List<Map<String, dynamic>> _challenges = [
    {
      "title": "تعلم 5 كلمات جديدة",
      "reward": "+50 نقطة",
      "progress": "3/5",
      "completed": false,
      "icon": "📚"
    },
    {
      "title": "أكمل سيناريو حياة يومية واحد",
      "reward": "+100 نقطة",
      "progress": "0/1",
      "completed": false,
      "icon": "☕"
    },
    {
      "title": "راجع البطاقات الذكية (SRS)",
      "reward": "+80 نقطة",
      "progress": "10/10",
      "completed": true,
      "icon": "⚡"
    },
    {
      "title": "استمع للنطق الصوتي لمدة دقيقتين",
      "reward": "+40 نقطة",
      "progress": "2/2 دقيقة",
      "completed": true,
      "icon": "🎧"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التحديات والمكافآت اليومية'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Column>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'سلسلة التعلم (Streak)',
                            style: AppTypography.body.copyWith(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '🔥 5 أيام متتالية',
                            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            'مجموع النقاط',
                            style: AppTypography.body.copyWith(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '⭐ 1,250 نقطة',
                            style: TextStyle(color: Color(0xFF34D399), fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'مهام اليوم لإبقاء نشاطك في القمة',
                  style: AppTypography.display.copyWith(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: _challenges.length,
                    itemBuilder: (context, index) {
                      final item = _challenges[index];
                      final bool isDone = item['completed'] as bool;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: AppBaseGlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: <Widget>[
                              Text(
                                item['icon']!,
                                style: const TextStyle(fontSize: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      item['title']!,
                                      style: AppTypography.display.copyWith(
                                        color: isDone ? Colors.white.withValues(alpha: 0.5) : Colors.white,
                                        fontSize: 16,
                                        decoration: isDone ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          item['reward']!,
                                          style: const TextStyle(color: Color(0xFF34D399), fontSize: 13, fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          '(${item['progress']})',
                                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDone ? const Color(0xFF34D399).withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                                ),
                                child: Icon(
                                  isDone ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
                                  color: isDone ? const Color(0xFF34D399) : Colors.white54,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
