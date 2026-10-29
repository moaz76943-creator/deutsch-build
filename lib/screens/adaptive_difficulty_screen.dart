import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';

class AdaptiveDifficultyScreen extends StatefulWidget {
  const AdaptiveDifficultyScreen({super.key});

  @override
  State<AdaptiveDifficultyScreen> createState() =>
      _AdaptiveDifficultyScreenState();
}

class _AdaptiveDifficultyScreenState extends State<AdaptiveDifficultyScreen> {
  bool _adaptiveActive = true;
  double _sensitivityLevel = 0.75;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام التكيّف الذكي المحلي (Adaptive)'),
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
                          Text('تفعيل التكيّف التلقائي',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('تعديل فترات البطاقات بناءً على أخطائك',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ],
                      )),
                      Switch(
                        value: _adaptiveActive,
                        activeThumbColor: const Color(0xFF38BDF8),
                        onChanged: (val) {
                          setState(() {
                            _adaptiveActive = val;
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
                      const Text('حساسية الخوارزمية للكلمات الصعبة',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Slider(
                        value: _sensitivityLevel,
                        activeColor: const Color(0xFF38BDF8),
                        inactiveColor: Colors.white24,
                        onChanged: (val) {
                          setState(() {
                            _sensitivityLevel = val;
                          });
                        },
                      ),
                      const SizedBox(height: 6),
                      const Text(
                          'كلما زادت الحساسية، قام النظام بتكرار الكلمات الصعبة بشكل أسرع في جلساتك.',
                          style:
                              TextStyle(color: Colors.white54, fontSize: 12)),
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
