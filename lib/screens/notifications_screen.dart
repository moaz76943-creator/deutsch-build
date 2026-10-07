import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> _notifications = const [
    {
      'title': 'حافظ على سلسلتك اليومية! 🔥',
      'body': 'أكملت 14 يوماً متتالياً! تدرب اليوم لمدة 5 دقائق للحفاظ على شارتك.',
      'time': 'منذ 15 دقيقة',
      'read': false,
      'icon': Icons.local_fire_department_rounded,
      'color': Color(0xFFF97316),
    },
    {
      'title': 'مراجعة الكلمات الجديدة 📚',
      'body': 'لديك 12 كلمة جاهزة للمراجعة الذكية بطريقة التكرار المتباعد.',
      'time': 'منذ ساعتين',
      'read': false,
      'icon': Icons.psychology_rounded,
      'color': Color(0xFF2563EB),
    },
    {
      'title': 'إنجاز جديد: بطل أدوات التعريف! 🏆',
      'body': 'حققت نسبة دقة 95% في اختبار der/die/das لهذا اليوم.',
      'time': 'أمس',
      'read': true,
      'icon': Icons.emoji_events_rounded,
      'color': Color(0xFFEAB308),
    },
    {
      'title': 'تحديث الحزم التعليمية 🌍',
      'body': 'تمت إضافة أمثلة وسياقات جديدة لحزم A1 و A2.',
      'time': 'منذ يومين',
      'read': true,
      'icon': Icons.update_rounded,
      'color': Color(0xFF10B981),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: const Text(
          'Notifications / الإشعارات',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final item = _notifications[index];
          final isRead = item['read'] as bool;
          final color = item['color'] as Color;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isRead ? Colors.white : const Color(0xFFF0FDF4).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isRead ? const Color(0xFFE2E8F0) : color.withValues(alpha: 0.4)),
              boxShadow: const [
                BoxShadow(color: Color(0x04000000), blurRadius: 8, offset: Offset(0, 3)),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(item['icon'] as IconData, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item['title'] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                            ),
                          ),
                          Text(
                            item['time'] as String,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['body'] as String,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
