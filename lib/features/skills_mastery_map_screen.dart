import 'package:flutter/material.dart';
import '../ui/app_design_system.dart';

class MasteryNode {
  final String skill;
  final double percentage;
  final IconData icon;
  final Color color;

  const MasteryNode(this.skill, this.percentage, this.icon, this.color);
}

class SkillsMasteryMapScreen extends StatelessWidget {
  const SkillsMasteryMapScreen({super.key});

  final List<MasteryNode> _skills = const [
    MasteryNode('المفردات (Wortschatz)', 0.85, Icons.book_rounded, Colors.blue),
    MasteryNode('حالات الإعراب (Fälle)', 0.62, Icons.biotech_rounded, Colors.purple),
    MasteryNode('الاستماع والفهم (Hören)', 0.74, Icons.hearing_rounded, Colors.teal),
    MasteryNode('تصريف الأفعال (Verben)', 0.58, Icons.bolt_rounded, Colors.orange),
    MasteryNode('بناء الجمل (Satzbau)', 0.69, Icons.sort_by_alpha_rounded, Colors.green),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('خريطة إتقاني للمهارات', style: AppStyles.title),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: _skills.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final s = _skills[index];
            return AppCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: s.color.withValues(alpha: 0.15),
                        child: Icon(s.icon, color: s.color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(s.skill, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      Text('${(s.percentage * 100).toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, color: s.color, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: s.percentage,
                    backgroundColor: Colors.grey.shade200,
                    color: s.color,
                    borderRadius: BorderRadius.circular(6),
                    minHeight: 8,
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
