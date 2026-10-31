import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';

class AiPronunciationCoachScreen extends StatefulWidget {
  const AiPronunciationCoachScreen({super.key});

  @override
  State<AiPronunciationCoachScreen> createState() => _AiPronunciationCoachScreenState();
}

class _AiPronunciationCoachScreenState extends State<AiPronunciationCoachScreen> {
  bool _isRecording = false;
  String _feedbackText = "اضغط على زر التسجيل وانطق الجملة أدناه بصوت واضح";
  Color _feedbackColor = Colors.white70;

  final String _targetSentence = "Guten Morgen, wie geht es Ihnen?";
  final String _targetTranslation = "صباح الخير، كيف حالك؟";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مدرب النطق الفردي (AI)'),
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
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: <Widget>[
                      const Text('🎯 انطق العبارة التالية:', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text(
                        _targetSentence,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _targetTranslation,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isRecording = !_isRecording;
                        if (_isRecording) {
                          _feedbackText = "جارٍ الاستماع لتحليلك الصوتي...";
                          _feedbackColor = const Color(0xFF38BDF8);
                        } else {
                          _feedbackText = "ممتاز! نطق الحروف الساكنة دقيق بنسبة 92% 🚀";
                          _feedbackColor = const Color(0xFF34D399);
                        }
                      });
                    },
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRecording ? const Color(0xFFEF4444) : const Color(0xFF38BDF8),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: (_isRecording ? const Color(0xFFEF4444) : const Color(0xFF38BDF8)).withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                        color: Colors.black,
                        size: 44,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                AppBaseGlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      const Text('نتيجة التحليل الذكي:', style: TextStyle(color: Colors.white54, fontSize: 13)),
                      const SizedBox(height: 8),
                      Text(
                        _feedbackText,
                        style: TextStyle(color: _feedbackColor, fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
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
