import 'package:flutter/material.dart';

class LessonsPathScreen extends StatelessWidget {
  final String languageName;

  const LessonsPathScreen({Key? key, required this.languageName}) : super(key: key);

  final List<Map<String, dynamic>> _units = const [
    {'unit': 1, 'title': 'الأساسيات والتحيات', 'level': 'A1', 'progress': 1.0, 'isCompleted': true},
    {'unit': 2, 'title': 'في المدينة والمواصلات', 'level': 'A1', 'progress': 0.75, 'isCompleted': false},
    {'unit': 3, 'title': 'المطعم والمأكولات', 'level': 'A1', 'progress': 0.30, 'isCompleted': false},
    {'unit': 4, 'title': 'العائلة والبيت', 'level': 'A2', 'progress': 0.0, 'isCompleted': false},
    {'unit': 5, 'title': 'العمل والمهن', 'level': 'A2', 'progress': 0.0, 'isCompleted': false},
    {'unit': 6, 'title': 'الصحة والعيادة', 'level': 'B1', 'progress': 0.0, 'isCompleted': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: Text('مسار دروس $languageName', style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _units.length,
        itemBuilder: (context, index) {
          final u = _units[index];
          final completed = u['isCompleted'] as bool;
          final progress = u['progress'] as double;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(color: Color(0x04000000), blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: completed ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF),
                  child: Icon(
                    completed ? Icons.check_circle_rounded : Icons.lock_open_rounded,
                    color: completed ? const Color(0xFF10B981) : const Color(0xFF2563EB),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('الوحدة ${u['unit']}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(u['level'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(u['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFF1F5F9),
                          valueColor: AlwaysStoppedAnimation<Color>(completed ? const Color(0xFF10B981) : const Color(0xFF2563EB)),
                        ),
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
