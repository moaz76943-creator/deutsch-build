import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'spaced_repetition.dart';
import 'mistake_bank.dart';

class FlashcardItem {
  final String id;
  final String frontText;
  final String backText;
  final String example;

  const FlashcardItem({
    required this.id,
    required this.frontText,
    required this.backText,
    required this.example,
  });
}

class InteractiveFlashcardsScreen extends StatefulWidget {
  final List<FlashcardItem> cards;
  final String locale;

  const InteractiveFlashcardsScreen({
    super.key,
    required this.cards,
    this.locale = 'de-DE',
  });

  @override
  State<InteractiveFlashcardsScreen> createState() => _InteractiveFlashcardsScreenState();
}

class _InteractiveFlashcardsScreenState extends State<InteractiveFlashcardsScreen>
    with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  late AnimationController _animController;
  late Animation<double> _animation;
  int _currentIndex = 0;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initTts() async {
    await _tts.setLanguage(widget.locale);
    await _tts.setSpeechRate(0.45);
  }

  void _flipCard() {
    HapticFeedback.selectionClick();
    if (_isFlipped) {
      _animController.reverse();
    } else {
      _animController.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  void _handleReview(bool remembered) async {
    if (widget.cards.isEmpty) return;
    HapticFeedback.lightImpact();

    final currentCard = widget.cards[_currentIndex];
    await SpacedRepetitionEngine.recordAnswer(
      wordId: currentCard.id,
      correct: remembered,
    );

    if (!remembered) {
      await MistakeBank.addMistake(currentCard.id);
    } else {
      await MistakeBank.removeMistake(currentCard.id);
    }

    if (_currentIndex < widget.cards.length - 1) {
      if (_isFlipped) {
        _animController.reverse();
        _isFlipped = false;
      }
      setState(() => _currentIndex++);
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🎉 رائع جداً!', textAlign: TextAlign.center),
        content: const Text(
          'أتممت مراجعة مجموعة البطاقات بنجاح وتم تحديث مستويات الحفظ تلقائياً.',
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('إنهاء المراجعة'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('البطاقات الذكية')),
        body: const Center(child: Text('لا توجد بطاقات للمراجعة حالياً')),
      );
    }

    final card = widget.cards[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('بطاقة ${_currentIndex + 1} من ${widget.cards.length}'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (_currentIndex + 1) / widget.cards.length,
                borderRadius: BorderRadius.circular(8),
                minHeight: 8,
              ),
              const SizedBox(height: 30),
              Expanded(
                child: GestureDetector(
                  onTap: _flipCard,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      final angle = _animation.value * pi;
                      final isUnder = (angle > pi / 2);
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(angle),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isUnder ? Colors.teal.shade300 : Colors.blueAccent.shade100,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isUnder ? Colors.teal : Colors.blueAccent).withValues(alpha: 0.12),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: isUnder
                              ? Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()..rotateY(pi),
                                  child: _buildBack(card),
                                )
                              : _buildFront(card),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('صعبة / لم أحفظ', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () => _handleReview(false),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('حفظتها تماماً', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () => _handleReview(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFront(FlashcardItem card) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton.filledTonal(
            icon: const Icon(Icons.volume_up_rounded, size: 28),
            onPressed: () => _tts.speak(card.frontText),
          ),
          const SizedBox(height: 24),
          Text(
            card.frontText,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            '👆 انقر لقلب البطاقة ومعرفة المعنى',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildBack(FlashcardItem card) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'الترجمة والمثال',
              style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            card.backText,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          if (card.example.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              card.example,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
            ),
          ],
          const Spacer(),
          Text(
            'قيّم حفظك عبر الأزرار بالأسفل',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
