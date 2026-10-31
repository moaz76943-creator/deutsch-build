import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';

class SmartNotificationsScreen extends StatefulWidget {
  const SmartNotificationsScreen({super.key});

  @override
  State<SmartNotificationsScreen> createState() =>
      _SmartNotificationsScreenState();
}

class _SmartNotificationsScreenState extends State<SmartNotificationsScreen> {
  bool _remindersEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات والتذكيرات الذكية'),
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
                AppBaseGlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('تذكير يومي لحماية الـ Streak',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('تنبيه لطيف في وقت فراغك للتعلم',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ],
                      )),
                      Switch(
                        value: _remindersEnabled,
                        activeThumbColor: const Color(0xFF38BDF8),
                        onChanged: (val) {
                          setState(() {
                            _remindersEnabled = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppBaseGlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text('وقت التذكير المفضل',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: _reminderTime,
                          );
                          if (picked != null) {
                            setState(() {
                              _reminderTime = picked;
                            });
                          }
                        },
                        child: Text(
                          _reminderTime.format(context),
                          style: const TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
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
}
