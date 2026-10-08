import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'spaced_repetition.dart';

class LearningAnalyticsScreen extends StatefulWidget {
  const LearningAnalyticsScreen({super.key});

  @override
  State<LearningAnalyticsScreen> createState() => _LearningAnalyticsScreenState();
}

class _LearningAnalyticsScreenState extends State<LearningAnalyticsScreen> {
  int _streak = 0;
  int _favoritesCount = 0;
  int _mistakesCount = 0;
  final Map<int, int> _stageDistribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
  int _totalTrackedWords = 0;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    
    final streak = prefs.getInt('streak_count') ?? 0;
    final favs = prefs.getStringList('user_favorite_words')?.length ?? 0;
    final mistakes = prefs.getStringList('user_mistakes_bank')?.length ?? 0;

    final rawSrs = prefs.getString('srs_records');
    final Map<int, int> stages = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    int total = 0;

    if (rawSrs != null) {
      final Map<String, dynamic> map = json.decode(rawSrs);
      total = map.length;
      for (final entry in map.values) {
        final item = SpacedRepetitionItem.fromMap(Map<String, dynamic>.from(entry));
        stages[item.stage] = (stages[item.stage] ?? 0) + 1;
      }
    }

    setState(() {
      _streak = streak;
      _favoritesCount = favs;
      _mistakesCount = mistakes;
      _stageDistribution.addAll(stages);
      _totalTrackedWords = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة الإحصائيات ورادار التقدم'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _buildStatCard('أيام الالتزام', '$_streak 🔥', Colors.orange),
                  const SizedBox(width: 12),
                  _buildStatCard('الكلمات المفضلة', '$_favoritesCount ⭐', Colors.amber.shade700),
                  const SizedBox(width: 12),
                  _buildStatCard('بنك الأخطاء', '$_mistakesCount 🎯', Colors.redAccent),
                ],
              ),
              const SizedBox(height: 28),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.insights_rounded, color: Colors.blueAccent),
                          const SizedBox(width: 8),
                          const Text(
                            'توزيع الذاكرة (صناديق لايتنر)',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Text(
                            'إجمالي: $_totalTrackedWords كلمة',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ...List.generate(5, (index) {
                        final stageNum = index + 1;
                        final count = _stageDistribution[stageNum] ?? 0;
                        final ratio = _totalTrackedWords > 0 ? (count / _totalTrackedWords) : 0.0;
                        final stageColors = [
                          Colors.red.shade400,
                          Colors.orange.shade400,
                          Colors.amber.shade600,
                          Colors.lightGreen.shade600,
                          Colors.green.shade700,
                        ];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'المستوى $stageNum ${stageNum == 5 ? '(الذاكرة الدائمة)' : ''}',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                  Text('$count كلمات', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: ratio,
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(6),
                                backgroundColor: Colors.grey.withValues(alpha: 0.12),
                                color: stageColors[index],
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
