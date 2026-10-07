import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SentenceScrambleScreen extends StatefulWidget {
  final String originalSentence;
  final String translation;
  final String locale;

  const SentenceScrambleScreen({
    super.key,
    required this.originalSentence,
    required this.translation,
    this.locale = 'de-DE',
  });

  @override
  State<SentenceScrambleScreen> createState() => _SentenceScrambleScreenState();
}

class _SentenceScrambleScreenState extends State<SentenceScrambleScreen> {
  final FlutterTts _tts = FlutterTts();
  late List<String> _correctTokens;
  List<String> _shuffledTokens = [];
  final List<String> _userConstructedTokens = [];
  bool? _isCorrect;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    _correctTokens = widget.originalSentence.trim().split(RegExp(r'\s+'));
    _shuffledTokens = List<String>.from(_correctTokens)..shuffle();
    _userConstructedTokens.clear();
    _isCorrect = null;
    _tts.setLanguage(widget.locale);
  }

  void _onWordPicked(int index) {
    if (_isCorrect == true) return;
    HapticFeedback.selectionClick();
    setState(() {
      final token = _shuffledTokens.removeAt(index);
      _userConstructedTokens.add(token);
    });

    if (_shuffledTokens.isEmpty) {
      _verifyResult();
    }
  }

  void _onWordRemoved(int index) {
    if (_isCorrect == true) return;
    HapticFeedback.selectionClick();
    setState(() {
      final token = _userConstructedTokens.removeAt(index);
      _shuffledTokens.add(token);
      _isCorrect = null;
    });
  }

  void _verifyResult() {
    final assembled = _userConstructedTokens.join(' ');
    final target = _correctTokens.join(' ');
    final success = (assembled == target);

    setState(() => _isCorrect = success);
    if (success) {
      HapticFeedback.heavyImpact();
      _tts.speak(widget.originalSentence);
    } else {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تركيب الجمل والعبارات'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // بطاقة الترجمة العربية
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Column(
                    children: [
                      const Text(
                        'ركّب الجملة المطابقة للمعنى التالي:',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.translation,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // منطقة تجميع الجملة
              Container(
                constraints: const Duration(milliseconds: 300) == Duration.zero ? null : const BoxConstraints(minHeight: 110),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isCorrect == true
                      ? Colors.green.shade50
                      : _isCorrect == false
                          ? Colors.red.shade50
                          : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _isCorrect == true
                        ? Colors.green
                        : _isCorrect == false
                            ? Colors.red
                            : Colors.blueAccent.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: _userConstructedTokens.isEmpty
                    ? Center(
                        child: Text(
                          'اضغط على الكلمات بالترتيب الصحيح هنا...',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(_userConstructedTokens.length, (i) {
                          return ActionChip(
                            label: Text(
                              _userConstructedTokens[i],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: Colors.blueAccent.withValues(alpha: 0.12),
                            onPressed: () => _onWordRemoved(i),
                          );
                        }),
                      ),
              ),
              const SizedBox(height: 30),

              // منطقة الكلمات المبعثرة المتبقية
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: List.generate(_shuffledTokens.length, (i) {
                  return ActionChip(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    label: Text(
                      _shuffledTokens[i],
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    onPressed: () => _onWordPicked(i),
                  );
                }),
              ),
              const Spacer(),

              // زر إعادة المحاولة
              if (_isCorrect != null)
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _isCorrect! ? Colors.green.shade700 : Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: Icon(_isCorrect! ? Icons.check_circle_rounded : Icons.refresh_rounded),
                  label: Text(
                    _isCorrect! ? 'أحسنت! إجابة صحيحة' : 'إعادة المحاولة',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _isCorrect! ? () => Navigator.pop(context) : () => setState(_initGame),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
