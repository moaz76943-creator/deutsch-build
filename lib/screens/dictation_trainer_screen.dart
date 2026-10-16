import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';

class DictationTrainerScreen extends StatefulWidget {
  const DictationTrainerScreen({super.key});

  @override
  State<DictationTrainerScreen> createState() => _DictationTrainerScreenState();
}

class _DictationTrainerScreenState extends State<DictationTrainerScreen> {
  final TextEditingController _answerController = TextEditingController();
  bool _checked = false;
  bool _isCorrect = false;

  final String _targetWord = "Verantwortung";
  final String _targetMeaning = "المسؤولية";

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مدرب الاستماع والتهجئة (Dictation)'),
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
                      const Icon(Icons.headphones_rounded, color: Color(0xFF38BDF8), size: 48),
                      const SizedBox(height: 12),
                      const Text('استمع للكلمة واكتبها إملائياً بصورة صحيحة', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text('المعنى المساعد: $_targetMeaning', style: const TextStyle(color: Color(0xFF34D399), fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      IconButton(
                        iconSize: 56,
                        color: const Color(0xFF38BDF8),
                        icon: const Icon(Icons.play_circle_fill_rounded),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('جارٍ تشغيل الصوت الإملائي ببطء...'), duration: Duration(seconds: 1)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _answerController,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'اكتب التهجئة الصحيحة هنا...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                if (_checked)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (_isCorrect ? const Color(0xFF34D399) : const Color(0xFFEF4444)).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _isCorrect ? 'إجابة صحيحة تماماً! أحسنت 🚀' : 'خطأ تهجئي بسيط، الكلمة الصحيحة هي: $_targetWord',
                      style: TextStyle(color: _isCorrect ? const Color(0xFF34D399) : const Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 14),
                      textAlign: TextAlign.center,
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
                    setState(() {
                      _checked = true;
                      _isCorrect = _answerController.text.trim().toLowerCase() == _targetWord.toLowerCase();
                    });
                  },
                  child: const Text('تحقق من التهجئة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
