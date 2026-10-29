
import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';

class StudyPlanGeneratorScreen extends StatefulWidget {
  const StudyPlanGeneratorScreen({super.key});

  @override
  State<StudyPlanGeneratorScreen > createState() => _StudyPlanGeneratorScreenState();
}

class _StudyPlanGeneratorScreenState extends State<StudyPlanGeneratorScreen> {
  double _dailyMinutes = 15;
  final String _goal = "تطوير المحادثة اليومية والسفر";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مولد جدول التعلم الذكي'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'خطتك المخصصة لتعلم اللغات',
                        style: AppTypography.display.copyWith(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'حدد وقتاً قصيرة يومياً وسيقوم النظام بجدولة الدروس والبطاقات تلقائياً.',
                        style: AppTypography.body.copyWith(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppBaseGlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'الوقت المخصص يومياً: ${_dailyMinutes.toInt()} دقيقة',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Slider(
                        value: _dailyMinutes,
                        min: 5,
                        max: 60,
                        divisions: 11,
                        activeColor: const Color(0xFF38BDF8),
                        inactiveColor: Colors.white24,
                        onChanged: (val) {
                          setState(() {
                            _dailyMinutes = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppBaseGlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'الهدف الأساسي:',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _goal,
                        style: const TextStyle(color: Color(0xFF34D399), fontSize: 15),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم توليد وتحديث جدولك المخصص بنجاح!'), backgroundColor: Color(0xFF34D399)),
                    );
                  },
                  child: const Text('حفظ وتطبيق الجدول', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
