import 'package:flutter/material.dart';
import '../services/progress_storage_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _streak = 14;
  int _points = 1450;
  int _accuracy = 98;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  void _fetchStats() async {
    final stats = await ProgressStorageService.getUserStats();
    setState(() {
      _streak = stats['streak'] as int;
      _points = stats['points'] as int;
      _accuracy = stats['accuracy'] as int;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: const Text('Analytics & Progress / لوحة التحليلات', style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('إجمالي النقاط المكتسبة', style: TextStyle(color: Colors.white70, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text('$_points Pts', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text('أداء ممتاز 🚀', style: TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 12)),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildHeaderMetric('$_streak يوم', 'سلسلة الالتزام', Icons.local_fire_department_rounded, Colors.orange),
                          Container(height: 30, width: 1, color: Colors.white24),
                          _buildHeaderMetric('$_accuracy%', 'معدل الدقة', Icons.verified_rounded, Colors.lightBlueAccent),
                          Container(height: 30, width: 1, color: Colors.white24),
                          _buildHeaderMetric('320', 'كلمة متقنة', Icons.auto_stories_rounded, Colors.amber),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('النشاط الأسبوعي / Weekly Activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildDayBar('الإثنين', 0.8, true),
                      _buildDayBar('الثلاثاء', 0.6, true),
                      _buildDayBar('الأربعاء', 0.9, true),
                      _buildDayBar('الخميس', 1.0, true),
                      _buildDayBar('الجمعة', 0.5, true),
                      _buildDayBar('السبت', 0.3, false),
                      _buildDayBar('الأحد', 0.0, false),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('توزيع المهارات اللغوية / Skill Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _buildSkillProgress('المفردات والكلمات (Vocabulary)', 0.85, const Color(0xFF2563EB)),
                      const SizedBox(height: 16),
                      _buildSkillProgress('تصريف الأفعال (Verbs Conjugation)', 0.72, const Color(0xFF10B981)),
                      const SizedBox(height: 16),
                      _buildSkillProgress('القواعد النحوية (Grammar Rules)', 0.64, const Color(0xFFF59E0B)),
                      const SizedBox(height: 16),
                      _buildSkillProgress('الاستماع والمحادثة (Listening & Speaking)', 0.78, const Color(0xFF8B5CF6)),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeaderMetric(String value, String label, IconData icon, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
      ],
    );
  }

  Widget _buildDayBar(String day, double heightFactor, bool isDone) {
    return Column(
      children: [
        Container(
          width: 22,
          height: 100 * (heightFactor > 0 ? heightFactor : 0.08),
          decoration: BoxDecoration(
            color: isDone ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(day.substring(0, 2), style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSkillProgress(String skill, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(skill, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
            Text('${(progress * 100).toInt()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
