import 'package:flutter/material.dart';
import 'lesson_session_screen.dart';

class LessonsPathScreen extends StatefulWidget {
  final String languageName;

  const LessonsPathScreen({Key? key, required this.languageName}) : super(key: key);

  @override
  State<LessonsPathScreen> createState() => _LessonsPathScreenState();
}

class _LessonsPathScreenState extends State<LessonsPathScreen> {
  final List<Map<String, dynamic>> _units = [
    {
      'unit': '1',
      'title': 'الأساسيات والتحيات / Greetings & Basics',
      'level': 'A1.1',
      'lessons': 6,
      'completed': 4,
      'isLocked': false,
      'color': const Color(0xFF2563EB),
    },
    {
      'unit': '2',
      'title': 'المطعم والتسوق / Shopping & Dining',
      'level': 'A1.2',
      'lessons': 8,
      'completed': 2,
      'isLocked': false,
      'color': const Color(0xFF10B981),
    },
    {
      'unit': '3',
      'title': 'الروتين اليومي والوقت / Daily Life & Time',
      'level': 'A2.1',
      'lessons': 8,
      'completed': 0,
      'isLocked': false,
      'color': const Color(0xFFF59E0B),
    },
    {
      'unit': '4',
      'title': 'العمل والمهن / Career & Profession',
      'level': 'A2.2',
      'lessons': 10,
      'completed': 0,
      'isLocked': true,
      'color': const Color(0xFF8B5CF6),
    },
    {
      'unit': '5',
      'title': 'السفر واستكشاف المدينة / Travel & City Life',
      'level': 'B1.1',
      'lessons': 12,
      'completed': 0,
      'isLocked': true,
      'color': const Color(0xFFEC4899),
    },
  ];

  void _startLesson(int index) async {
    final u = _units[index];
    if (u['isLocked'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('هذه الوحدة مقفلة حالياً. أكمل الوحدات السابقة لفتحها! 🔒')),
      );
      return;
    }

    final finished = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonSessionScreen(
          unitTitle: u['title'],
          level: u['level'],
        ),
      ),
    );

    if (finished == true && mounted) {
      setState(() {
        if (u['completed'] < u['lessons']) {
          u['completed'] += 1;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Learning Path / مسار ${widget.languageName}', style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold)),
            const Text('انقر على أي وحدة لبدء الدرس التفاعلي', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        itemCount: _units.length,
        itemBuilder: (context, index) {
          final u = _units[index];
          final isLocked = u['isLocked'] as bool;
          final total = u['lessons'] as int;
          final done = u['completed'] as int;
          final progress = done / total;
          final unitColor = u['color'] as Color;

          return Column(
            children: [
              InkWell(
                onTap: () => _startLesson(index),
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isLocked ? const Color(0xFFF1F5F9) : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: isLocked ? const Color(0xFFE2E8F0) : unitColor.withValues(alpha: 0.3)),
                    boxShadow: isLocked
                        ? []
                        : [BoxShadow(color: unitColor.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: isLocked ? const Color(0xFFCBD5E1) : unitColor,
                            child: Icon(
                              isLocked ? Icons.lock_outline_rounded : (done == total ? Icons.check_rounded : Icons.play_arrow_rounded),
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'الوحدة ${u['unit']} • ${u['level']}',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isLocked ? const Color(0xFF94A3B8) : unitColor),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  u['title'] as String,
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isLocked ? const Color(0xFF64748B) : const Color(0xFF0F172A)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(unitColor),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('$done من $total دروس مكتملة', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          Text('${(progress * 100).toInt()}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isLocked ? const Color(0xFF94A3B8) : unitColor)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (index < _units.length - 1)
                Container(
                  width: 3,
                  height: 28,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
