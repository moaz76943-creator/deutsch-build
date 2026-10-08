import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ui/app_design_system.dart';
import '../ui/app_directional_text.dart';
import 'unified_learning_session.dart';

class SmartMistakeBankScreen extends StatefulWidget {
  const SmartMistakeBankScreen({super.key});

  @override
  State<SmartMistakeBankScreen> createState() => _SmartMistakeBankScreenState();
}

class _SmartMistakeBankScreenState extends State<SmartMistakeBankScreen> {
  Map<String, dynamic> _mistakes = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMistakes();
  }

  Future<void> _loadMistakes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('error_fingerprints') ?? '{}';
    setState(() {
      _mistakes = json.decode(raw);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('دفتر أخطائي الذكي', style: AppStyles.title),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _mistakes.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text('سجل أخطائك نظيف حالياً! كل إجاباتك السابقة كانت صحيحة 🎉',
                          textAlign: TextAlign.center, style: AppStyles.subtitle),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _mistakes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final key = _mistakes.keys.elementAt(index);
                      final data = _mistakes[key];
                      final expected = data['expected'] ?? '';
                      final actual = data['actual'] ?? '';
                      final pattern = data['pattern'] ?? 'قاعدة نحوية';
                      final freq = data['frequency'] ?? 1;

                      return AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text('تكرر $freq مرات', style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                                Text(pattern, style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text('الصحيح:', style: AppStyles.body.copyWith(fontWeight: FontWeight.bold)),
                            AppDirectionalText.target(expected, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('محاولتك السابقة: $actual', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                icon: const Icon(Icons.refresh_rounded, size: 18),
                                label: const Text('تدرب عليها الآن'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => UnifiedLearningSession(
                                        tasks: [
                                          LearningTask(
                                            id: 'mistake_retry_$index',
                                            prompt: 'أعد كتابة التعبير الصحيح لـ: $pattern',
                                            correctAnswer: expected,
                                            explanation: 'المحاولة الصحيحة لمعالجة الخطأ السابق.',
                                            grammarPattern: pattern,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
