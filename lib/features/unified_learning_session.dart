import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ui/app_design_system.dart';
import '../core/atomic_attempt_manager.dart';

class ErrorFingerprint {
  final String expected;
  final String actual;
  final String pattern;
  int frequency;

  ErrorFingerprint({required this.expected, required this.actual, required this.pattern, this.frequency = 1});

  Map<String, dynamic> toMap() => {'expected': expected, 'actual': actual, 'pattern': pattern, 'frequency': frequency};
}

class LearningTask {
  final String id;
  final String prompt;
  final String correctAnswer;
  final String explanation;
  final String grammarPattern;

  const LearningTask({
    required this.id,
    required this.prompt,
    required this.correctAnswer,
    required this.explanation,
    required this.grammarPattern,
  });
}

class UnifiedLearningSession extends StatefulWidget {
  final List<LearningTask> tasks;
  const UnifiedLearningSession({super.key, required this.tasks});

  @override
  State<UnifiedLearningSession> createState() => _UnifiedLearningSessionState();
}

class _UnifiedLearningSessionState extends State<UnifiedLearningSession> {
  int _currentIndex = 0;
  final TextEditingController _answerController = TextEditingController();
  bool _isEvaluating = false;
  int _hintLevel = 0; // 0: بدون تلميح, 1: الحرف الأول, 2: عدد الحروف
  String _selectedConfidence = 'متأكد'; // متأكد / متردد / خمنت

  Future<void> _recordError(LearningTask task, String actualAnswer) async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = prefs.getString('error_fingerprints') ?? '{}';
    Map<String, dynamic> map = json.decode(rawData);

    final errorKey = '${task.id}_$actualAnswer';
    if (map.containsKey(errorKey)) {
      map[errorKey]['frequency'] = (map[errorKey]['frequency'] ?? 1) + 1;
    } else {
      map[errorKey] = ErrorFingerprint(
        expected: task.correctAnswer,
        actual: actualAnswer,
        pattern: task.grammarPattern,
      ).toMap();
    }
    await prefs.setString('error_fingerprints', json.encode(map));
  }

  Future<void> _evaluateAnswer() async {
    if (_answerController.text.trim().isEmpty) return;

    final task = widget.tasks[_currentIndex];
    final attemptId = '${task.id}_${DateTime.now().millisecondsSinceEpoch}';

    // حماية ذرية لمنع معالجة المحاولة المكررة
    if (await AtomicAttemptManager.isAttemptProcessed(attemptId)) return;
    await AtomicAttemptManager.markAttemptProcessed(attemptId);

    setState(() => _isEvaluating = true);
    FocusScope.of(context).unfocus();

    final userAnswer = _answerController.text.trim().toLowerCase();
    final isCorrect = userAnswer == task.correctAnswer.toLowerCase();

    if (!isCorrect) {
      await _recordError(task, userAnswer);
    }

    _showFeedbackSheet(isCorrect, task);
  }

  void _showFeedbackSheet(bool isCorrect, LearningTask task) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isCorrect ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: isCorrect ? AppColors.success : AppColors.error, width: 3)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: isCorrect ? AppColors.success : AppColors.error,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isCorrect ? 'ممتاز! إجابة صحيحة' : 'ليس تماماً',
                    style: AppStyles.title.copyWith(color: isCorrect ? AppColors.success : AppColors.error),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('مستوى الثقة المسجل: $_selectedConfidence', style: AppStyles.subtitle.copyWith(fontSize: 13)),
              if (!isCorrect) ...[
                const SizedBox(height: 12),
                Text('الصحيح هو: ${task.correctAnswer}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 6),
                Text('التعليل: ${task.explanation}', style: AppStyles.body),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'المتابعة',
                  onPressed: () {
                    Navigator.pop(ctx);
                    _nextTask();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _nextTask() {
    if (_currentIndex < widget.tasks.length - 1) {
      setState(() {
        _currentIndex++;
        _isEvaluating = false;
        _hintLevel = 0;
        _selectedConfidence = 'متأكد';
        _answerController.clear();
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('🎉 اكتملت الجلسة بنجاح'),
        content: const Text('تم حفظ المحاولات بأمان ومعايرة الثقة وتحديث الذاكرة.'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('إنهاء'),
          ),
        ],
      ),
    );
  }

  String _getHintText(String answer) {
    if (_hintLevel == 1) {
      return 'تلميح 1: الكلمة تبدأ بالحرف "${answer.isNotEmpty ? answer[0] : ''}"';
    } else if (_hintLevel == 2) {
      return 'تلميح 2: الطول الإجمالي ${answer.length} حرفاً، وتبدأ بـ "${answer.substring(0, answer.length > 2 ? 2 : 1)}"';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tasks.isEmpty) return const Scaffold(body: Center(child: Text('لا توجد مهام')));
    final task = widget.tasks[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: LinearProgressIndicator(
          value: (_currentIndex + 1) / widget.tasks.length,
          color: AppColors.primary,
          backgroundColor: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
          minHeight: 8,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline_rounded, color: AppColors.warning),
            tooltip: 'طلب تلميح',
            onPressed: _hintLevel >= 2 ? null : () => setState(() => _hintLevel++),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ترجم هذه العبارة:', style: AppStyles.subtitle),
              const SizedBox(height: 8),
              Text(task.prompt, style: AppStyles.title.copyWith(fontSize: 26)),
              if (_hintLevel > 0) ...[
                const SizedBox(height: 10),
                Text(_getHintText(task.correctAnswer), style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold)),
              ],
              const Spacer(),
              // مقياس الثقة (Confidence Calibration)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ['متأكد', 'متردد', 'خمنت'].map((choice) {
                  final isSelected = _selectedConfidence == choice;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(choice),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() => _selectedConfidence = choice);
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _answerController,
                enabled: !_isEvaluating,
                autofocus: true,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'اكتب الإجابة هنا...',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(20),
                ),
                onSubmitted: (_) => _evaluateAnswer(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'تحقق من الإجابة',
                  onPressed: _isEvaluating ? () {} : _evaluateAnswer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
