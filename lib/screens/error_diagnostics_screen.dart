import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';

class ErrorDiagnosticsScreen extends StatelessWidget {
  const ErrorDiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> logs = [
      {
        "time": "04:00 AM",
        "type": "INFO",
        "msg": "تم تهيئة قاعدة البيانات المحلية بنجاح."
      },
      {
        "time": "03:55 AM",
        "type": "SUCCESS",
        "msg": "تم مزامنة الكلمات الجديدة مع سجل SRS."
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل وتشخيص الأخطاء المحلية'),
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
                const Text('سجل الأحداث والأخطاء البرمجية (Logs):',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: AppBaseGlassCard(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(log['type']!,
                                      style: const TextStyle(
                                          color: Color(0xFF34D399),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                  Text(log['time']!,
                                      style: const TextStyle(
                                          color: Colors.white54, fontSize: 11)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(log['msg']!,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
