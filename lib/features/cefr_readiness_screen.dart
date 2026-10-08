import 'package:flutter/material.dart';
import '../ui/app_design_system.dart';

class SkillReadiness {
  final String skillName;
  final double score; // من 0.0 إلى 1.0

  const SkillReadiness(this.skillName, this.score);
}

class CefrReadinessScreen extends StatelessWidget {
  const CefrReadinessScreen({super.key});

  final List<SkillReadiness> _readiness = const [
    SkillReadiness('المفردات المعجمية (Wortschatz)', 0.88),
    SkillReadiness('القواعد والإعراب (Grammatik & Fälle)', 0.65),
    SkillReadiness('الاستماع والفهم (Hörverstehen)', 0.70),
    SkillReadiness('بناء الجمل والإنتاج (Satzbau)', 0.58),
  ];

  @override
  Widget build(BuildContext context) {
    final overall = _readiness.map((e) => e.score).reduce((a, b) => a + b) / _readiness.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('مؤشر الجاهزية لـ CEFR B1', style: AppStyles.title),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppCard(
              child: Column(
                children: [
                  const Text('مستوى الاستعداد الإجمالي الحالي', style: AppStyles.subtitle),
                  const SizedBox(height: 12),
                  Text('${(overall * 100).toInt()}%', style: AppStyles.title.copyWith(fontSize: 40, color: AppColors.primary)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: overall,
                    backgroundColor: Colors.grey.shade200,
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                    minHeight: 10,
                  ),
                  const SizedBox(height: 12),
                  const Text('مؤشر تقديري مبني على سجل محاولاتك ودقة الإجابات محلياً.', textAlign: TextAlign.center, style: AppStyles.body),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('تفصيل الجاهزية حسب المهارة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            ..._readiness.map((skill) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(skill.skillName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('${(skill.score * 100).toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, color: skill.score >= 0.7 ? AppColors.success : AppColors.warning)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: skill.score,
                          backgroundColor: Colors.grey.shade200,
                          color: skill.score >= 0.7 ? AppColors.success : AppColors.warning,
                          borderRadius: BorderRadius.circular(6),
                          minHeight: 6,
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
