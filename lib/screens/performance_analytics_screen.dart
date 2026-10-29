import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';

class PerformanceAnalyticsScreen extends StatelessWidget {
  const PerformanceAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحليل الأداء ونقاط الضعف الذكية'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Text('📊', style: TextStyle(fontSize: 32)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'معدل التقدم العام',
                              style: AppTypography.display.copyWith(color: Colors.white, fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'نسبة إتقان الكلمات والقواعد وصلت إلى 84% هذا الأسبوع.',
                              style: AppTypography.body.copyWith(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'خريطة الضعف والتركيز (Weakness Heatmap)',
                  style: AppTypography.display.copyWith(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 12),
                AppBaseGlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'الأقسام التي تحتاج إلى مراجعة إضافية:',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 14),
                      _buildWeaknessItem('قواعد الأفعال المركبة (German)', 0.75, const Color(0xFFEF4444)),
                      const SizedBox(height: 12),
                      _buildWeaknessItem('أدوات التعريف والتنكير (Articles)', 0.50, const Color(0xFFF59E0B)),
                      const SizedBox(height: 12),
                      _buildWeaknessItem('مفردات الحياة اليومية (Daily Life)', 0.20, const Color(0xFF34D399)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeaknessItem(String title, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            Text('${(progress * 100).toInt()}% نسبة الخطأ', style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white24,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }
}
