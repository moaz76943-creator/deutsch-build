import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';

class AiPlacementTestScreen extends StatefulWidget {
  const AiPlacementTestScreen({super.key});

  @override
  State<AiPlacementTestScreen> createState() => _AiPlacementTestScreenState();
}

class _AiPlacementTestScreenState extends State<AiPlacementTestScreen> {
  int _currentStep = 1;
  final int _totalSteps = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اختبار تحديد المستوى الذكي ($_currentStep/$_totalSteps)'),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'السؤال الأول:',
                        style: TextStyle(color: Color(0xFF38BDF8), fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'اختر الجملة الصحيحة للألمانية للتعبير عن: "أنا أتعلم اللغة الألمانية كل يوم."',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      _buildOption('Ich lerne jeden Tag Deutsch.'),
                      const SizedBox(height: 10),
                      _buildOption('Lerne ich Deutsch Tag.'),
                      const SizedBox(height: 10),
                      _buildOption('Deutsch ich lerne.'),
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
                    setState(() {
                      if (_currentStep < _totalSteps) {
                        _currentStep++;
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم تحليل مستواك بنجاح وتعيين المستوى (A2)!'), backgroundColor: Color(0xFF34D399)),
                        );
                      }
                    });
                  },
                  child: Text(_currentStep < _totalSteps ? 'السؤال التالي' : 'عرض النتيجة النهائية', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOption(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
    );
  }
}
