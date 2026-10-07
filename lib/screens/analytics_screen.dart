import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('لوحة المتابعة والتحليلات', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة مؤشر الإتقان الكلي
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('مستوى الإنجاز الأسبوعي', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        SizedBox(height: 6),
                        Text('تطور ملحوظ!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('أتممت 85% من أهداف الحفظ والمراجعة لهذا الأسبوع.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Stack(
                    alignment: Alignment.center,
                    children: const [
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: CircularProgressIndicator(
                          value: 0.85,
                          strokeWidth: 8,
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                        ),
                      ),
                      Text('85%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('مستوى إتقان المهارات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 12),
            _buildSkillBar('المفردات (Wortschatz)', 0.88, const Color(0xFF2563EB)),
            _buildSkillBar('القواعد النحوية (Grammatik)', 0.65, const Color(0xFFF59E0B)),
            _buildSkillBar('أدوات التعريف (Artikel)', 0.92, const Color(0xFFEC4899)),
            _buildSkillBar('تصريف الأفعال (Verben)', 0.70, const Color(0xFF10B981)),
            const SizedBox(height: 24),

            const Text('نشاط التعلم خلال الأيام الأخيرة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDayActivity('السبت', 35, true),
                  _buildDayActivity('الأحد', 50, true),
                  _buildDayActivity('الإثنين', 20, true),
                  _buildDayActivity('الثلاثاء', 45, true),
                  _buildDayActivity('الأربعاء', 60, true),
                  _buildDayActivity('الخميس', 15, false),
                  _buildDayActivity('الجمعة', 40, true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillBar(String label, double value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
              Text('${(value * 100).toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayActivity(String day, int count, bool active) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 60,
          decoration: BoxDecoration(
            color: active ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 32,
            height: count.toDouble(),
            decoration: BoxDecoration(
              color: active ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(day, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
      ],
    );
  }
}
