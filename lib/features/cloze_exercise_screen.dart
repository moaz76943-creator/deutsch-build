import 'package:flutter/material.dart';
import '../ui/app_design_system.dart';

class ClozeItem {
  final String sentenceStart;
  final String sentenceEnd;
  final String correctAnswer;
  final String translation;
  final String explanation;

  const ClozeItem({
    required this.sentenceStart,
    required this.sentenceEnd,
    required this.correctAnswer,
    required this.translation,
    required this.explanation,
  });
}

class ClozeExerciseScreen extends StatefulWidget {
  final ClozeItem item;
  const ClozeExerciseScreen({
    super.key,
    this.item = const ClozeItem(
      sentenceStart: 'Ich fahre mit ',
      sentenceEnd: ' Auto.',
      correctAnswer: 'dem',
      translation: 'أنا أذهب بالسيارة.',
      explanation: 'حرف الجر يتطلب حالة إعرابية خاصة في هذا السياق.',
    ),
  });

  @override
  State<ClozeExerciseScreen> createState() => _ClozeExerciseScreenState();
}

class _ClozeExerciseScreenState extends State<ClozeExerciseScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isAnswered = false;
  bool _isCorrect = false;

  void _checkAnswer() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _isAnswered = true;
      _isCorrect = _controller.text.trim().toLowerCase() == widget.item.correctAnswer.toLowerCase();
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('أكمل الفراغ', style: AppStyles.title), backgroundColor: AppColors.background, elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.item.translation, style: AppStyles.subtitle.copyWith(fontSize: 18), textAlign: TextAlign.center),
              const SizedBox(height: 40),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(widget.item.sentenceStart, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Container(
                    width: 90,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextField(
                      controller: _controller,
                      enabled: !_isAnswered,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
                      ),
                    ),
                  ),
                  Text(widget.item.sentenceEnd, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              const Spacer(),
              if (_isAnswered)
                AppCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(_isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded, color: _isCorrect ? AppColors.success : AppColors.error),
                          const SizedBox(width: 8),
                          Text(_isCorrect ? 'صحيح!' : 'الإجابة هي: ${widget.item.correctAnswer}', 
                              style: TextStyle(color: _isCorrect ? AppColors.success : AppColors.error, fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(widget.item.explanation, style: AppStyles.body),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              AppButton(
                text: _isAnswered ? 'المتابعة' : 'تحقق',
                onPressed: _isAnswered ? () => Navigator.pop(context) : _checkAnswer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
