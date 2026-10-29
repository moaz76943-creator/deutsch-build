import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';

class EyeCareSettingsScreen extends StatefulWidget {
  const EyeCareSettingsScreen({super.key});

  @override
  State<EyeCareSettingsScreen> createState() => _EyeCareSettingsScreenState();
}

class _EyeCareSettingsScreenState extends State<EyeCareSettingsScreen> {
  bool _blueLightFilter = true;
  double _brightnessLevel = 0.8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('وضع القراءة الليلية وحماية العين'),
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
                          Text('فلتر الضوء الأزرق المريح',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('تخفيف إجهاد العين أثناء جلسات الليل',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ],
                      )),
                      Switch(
                        value: _blueLightFilter,
                        activeThumbColor: const Color(0xFF38BDF8),
                        onChanged: (val) {
                          setState(() {
                            _blueLightFilter = val;
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
                      const Text('مستوى التباين والسطوع الداخلي',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Slider(
                        value: _brightnessLevel,
                        activeColor: const Color(0xFF38BDF8),
                        inactiveColor: Colors.white24,
                        onChanged: (val) {
                          setState(() {
                            _brightnessLevel = val;
                          });
                        },
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
