import 'package:flutter/material.dart';

class CurriculumHubScreen extends StatelessWidget {
  const CurriculumHubScreen({super.key});

  static const List<Map<String, String>> missions = [
    {'id': '1', 'title': 'التعارف والمحادثة الأولى', 'level': 'A1', 'icon': 'handshake'},
    {'id': '2', 'title': 'في المطار ومكتب الجوازات', 'level': 'A1', 'icon': 'flight'},
    {'id': '3', 'title': 'حجز الفندق والإقامة', 'level': 'A1', 'icon': 'hotel'},
    {'id': '4', 'title': 'المطعم وطلب الوجبات', 'level': 'A1', 'icon': 'restaurant'},
    {'id': '5', 'title': 'المواصلات العامة وشراء التذاكر', 'level': 'A1', 'icon': 'train'},
    {'id': '6', 'title': 'في السوبرماركت والتسوق', 'level': 'A1', 'icon': 'shopping_cart'},
    {'id': '7', 'title': 'زيارة الطبيب والصيدلية', 'level': 'A2', 'icon': 'local_hospital'},
    {'id': '8', 'title': 'فتح حساب بنكي والمعاملات المالية', 'level': 'A2', 'icon': 'account_balance'},
    {'id': '9', 'title': 'البحث عن سكن وتوقيع العقد', 'level': 'A2', 'icon': 'home'},
    {'id': '10', 'title': 'مقابلة العمل والتقديم الوظيفي', 'level': 'B1', 'icon': 'work'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المناهج والمهام الحياتية (50 مهمة)'),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: missions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = missions[index];
          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                child: Text(item['level']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
              ),
              title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('المهمة رقم ${item['id']} من مسار الإتقان الواقعي'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('بدء تدريب: ${item['title']}')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
