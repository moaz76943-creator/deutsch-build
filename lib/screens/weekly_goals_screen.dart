import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';

class WeeklyGoalsScreen extends StatelessWidget {
  const WeeklyGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('منظم الأهداف والتقدم الأسبوعي'),
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
                AppBaseGlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('هدف الأسبوع الحالي',
                          style: TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      const Text('حفظ 50 كلمة جديدة وإتمام 5 جلسات مراجعة',
                          style: TextStyle(color: Colors.white, fontSize: 14)),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: 0.7,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF34D399)),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 8),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('70% من الهدف مكتمل',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12)),
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
                      const Text('إحصائيات إنجاز الأيام',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildDayRow('السبت', '25 دقيقة', true),
                      _buildDayRow('الأحد', '30 دقيقة', true),
                      _buildDayRow('الإثنين', '15 دقيقة', true),
                      _buildDayRow('الثلاثاء', '0 دقيقة', false),
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

  Widget _buildDayRow(String day, String stringDuration, bool completed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(child: Text(day, style: const TextStyle(color: Colors.white, fontSize: 14))),
          Row(
            children: <Widget>[
              Text(stringDuration,
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(width: 10),
              Icon(
                completed
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: completed ? const Color(0xFF34D399) : Colors.white38,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
