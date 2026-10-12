import 'package:flutter/material.dart';
import 'dart:math';
import '../core/srs/review_command_port.dart';
import '../core/audio/offline_audio_manager.dart';
import '../services/database_service.dart';

Future<List<Map<String, dynamic>>> loadFlashcardsSafe(String targetLangCode) async {
  final db = await DatabaseService.instance.contentDb;
  return await db.rawQuery(
    '''
    SELECT l.lexeme_id, l.article, l.lemma, l.plural, e.translation_ar, e.sentence 
    FROM lexemes AS l 
    LEFT JOIN examples AS e 
      ON e.concept_id = l.concept_id AND e.language_code = l.language_code 
    WHERE l.language_code = ? 
    LIMIT 10
    ''',
    [targetLangCode], 
  );
}

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key}); 
  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFlipped = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(_flipController);
  }

  @override
  void dispose() {
    _flipController.dispose();
    OfflineAudioManager.instance.stop(); 
    super.dispose();
  }

  void _toggleFlip() {
    if (_isSubmitting) return;
    setState(() {
      _isFlipped = !_isFlipped;
    });
    if (_isFlipped) {
      _flipController.forward();
      OfflineAudioManager.instance.speak("das Buch"); 
    } else {
      _flipController.reverse();
    }
  }

  Future<void> _handleRating(ReviewRating rating) async {
    if (_isSubmitting) return; 
    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(milliseconds: 300)); 
    
    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _toggleFlip(); 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مراجعة اليوم', style: TextStyle(fontFamily: 'Cairo')),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: LinearProgressIndicator(value: 0.3, backgroundColor: Colors.white24),
            ),
            Expanded(
              child: GestureDetector(
                onTap: _toggleFlip,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _flipAnimation,
                    builder: (context, child) {
                      final angle = _flipAnimation.value * pi;
                      final isFront = angle < pi / 2;
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateX(angle),
                        child: isFront ? _buildFrontAppBaseGlassCard() : _buildBackAppBaseGlassCard(),
                      );
                    },
                  ),
                ),
              ),
            ),
            if (_isFlipped)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: _isSubmitting 
                  ? const CircularProgressIndicator()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildRatingButton('مجدداً', Colors.redAccent, ReviewRating.again),
                        _buildRatingButton('صعب', Colors.orangeAccent, ReviewRating.hard),
                        _buildRatingButton('جيد', Colors.blueAccent, ReviewRating.good),
                        _buildRatingButton('سهل', Colors.green, ReviewRating.easy),
                      ],
                    ),
              )
            else
              const Padding(
                padding: EdgeInsets.all(40.0),
                child: Text('اضغط للكشف والاستماع', style: TextStyle(color: Colors.white54)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrontAppBaseGlassCard() {
    return Container(
      width: 320,
      height: 400,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
      ),
      alignment: Alignment.center,
      child: const Text(
        'das Buch', 
        style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildBackAppBaseGlassCard() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateX(pi),
      child: Container(
        width: 320,
        height: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF334155),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('الكتاب', style: TextStyle(fontSize: 32, fontFamily: 'Cairo', color: Colors.white)),
            SizedBox(height: 20),
            Text('Ich lese ein Buch.', style: TextStyle(fontSize: 18, color: Colors.white70)),
            Text('أنا أقرأ كتاباً.', style: TextStyle(fontSize: 18, fontFamily: 'Cairo', color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingButton(String label, Color color, ReviewRating rating) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withAlpha(51),
        foregroundColor: color,
        elevation: 0,
        minimumSize: const Size(70, 56), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () => _handleRating(rating),
      child: Text(label, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
    );
  }
}
