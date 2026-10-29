import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';

class SleepLearningScreen extends StatefulWidget {
  const SleepLearningScreen({super.key});

  @override
  State<SleepLearningScreen> createState() => _SleepLearningScreenState();
}

class _SleepLearningScreenState extends State<SleepLearningScreen> {
  bool _isPlaying = false;
  double _volume = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('وضع التعلم أثناء النوم والاسترخاء'),
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
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: <Widget>[
                      const Text('🌙', style: TextStyle(fontSize: 40)),
                      const SizedBox(height: 12),
                      Text(
                        'جلسة ترسيخ الذاكرة اللاواعية',
                        style: AppTypography.display.copyWith(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'استمع للكلمات والجمل بنبرة هادئة ومريحة أثناء النوم أو الاسترخاء لترسيخها في الذاكرة طويلة المدى.',
                        style: AppTypography.body.copyWith(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                AppBaseGlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      Text(
                        _isPlaying ? 'جارٍ التشغيل... (صوت هادئ)' : 'متوقف مؤقتاً',
                        style: TextStyle(
                          color: _isPlaying ? const Color(0xFF34D399) : Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      IconButton(
                        iconSize: 64,
                        color: const Color(0xFF38BDF8),
                        icon: Icon(_isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded),
                        onPressed: () {
                          setState(() {
                            _isPlaying = !_isPlaying;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: <Widget>[
                          const Icon(Icons.volume_down, color: Colors.white70),
                          Expanded(
                            child: Slider(
                              value: _volume,
                              activeColor: const Color(0xFF38BDF8),
                              inactiveColor: Colors.white24,
                              onChanged: (val) {
                                setState(() {
                                  _volume = val;
                                });
                              },
                            ),
                          ),
                          const Icon(Icons.volume_up, color: Colors.white70),
                        ],
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
