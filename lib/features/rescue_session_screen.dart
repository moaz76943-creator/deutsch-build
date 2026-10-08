import 'package:flutter/material.dart';
import '../ui/app_design_system.dart';
import 'unified_learning_session.dart';

class RescueSessionScreen extends StatelessWidget {
  const RescueSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('جلسة إنقاذ سريعة (2 دقيقة)', style: AppStyles.title),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Column(
                  children: [
                    const Icon(Icons.bolt_rounded, size: 48, color: AppColors.warning),
                    const SizedBox(height: 12),
                    const Text('حافظ على استمراريتك اليوم 🔥', style: AppStyles.title),
                    const SizedBox(height: 8),
                    const Text(
                      'إذا لم يكن لديك وقت كافٍ، هذه الجلسة مخصصة لإنقاذ كلمتين معرّضتين للنسيان خلال دقيقتين فقط.',
                      textAlign: TextAlign.center,
                      style: AppStyles.body,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              AppButton(
                text: 'ابدأ الإنقاذ السريع الآن',
                icon: Icons.timer_outlined,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UnifiedLearningSession(
                        tasks: [
                          LearningTask(
                            id: 'rescue_1',
                            prompt: 'شكراً جزيلاً',
                            correctAnswer: 'Vielen Dank',
                            explanation: 'عبارة شائعة للتعبير عن الامتنان.',
                            grammarPattern: 'Fixed Phrase',
                          ),
                          LearningTask(
                            id: 'rescue_2',
                            prompt: 'إلى اللقاء',
                            correctAnswer: 'Auf Wiedersehen',
                            explanation: 'الصيغة الرسمية لوداع الأشخاص.',
                            grammarPattern: 'Fixed Phrase',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
