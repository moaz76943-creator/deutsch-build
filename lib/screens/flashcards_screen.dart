import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import '../core/srs/review_command_port.dart';

// --- دوال الأمان وقاعدة البيانات (تم بناؤها في P0) ---
Future<List<Map<String, dynamic>>> loadFlashcardsSafe(String targetLangCode) async {
  return []; // مؤقت لحين ربط DB
}

Future<void> handleCardRating(
  ReviewCommandPort? srsPort,
  String cardId, 
  ReviewRating rating, 
  bool wasHinted
) async {
  if (srsPort == null) return;
  final command = ReviewCommand(
    reviewId: const Uuid().v4(),
    sourceLanguageId: 'ar',
    targetLanguageId: 'de',
    cardId: cardId,
    facetKey: 'core_meaning',
    pairEpoch: 1,
    rating: rating,
    hinted: wasHinted,
  );
  await srsPort.submit(command);
}

// --- كائن وهمي لمشغل الصوت لضمان عمل الواجهة بدون أخطاء مؤقتاً ---
class OfflineAudioPoolStub {
  static final OfflineAudioPoolStub instance = OfflineAudioPoolStub();
  void stop() {
    debugPrint("تم استدعاء إيقاف الصوت.");
  }
}

// --- واجهة البطاقات المعتمدة (P1) ---
class FlashcardsScreen extends StatefulWidget {
  // إصلاح التحذير رقم 2: استخدام super parameter
  const FlashcardsScreen({super.key}); 

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    // 1. زمن التقليب المعتمد (200ms) لمنع الإرهاق الإدراكي
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(_flipController);
  }

  @override
  void dispose() {
    // 2. حماية الذاكرة: إغلاق المتحكمات لمنع الـ Memory Leaks
    _flipController.dispose();
    
    // إيقاف الصوت النشط عند الخروج من الشاشة
    OfflineAudioPoolStub.instance.stop();
    
    super.dispose();
  }

  void _toggleFlip() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
    if (_isFlipped) {
      _flipController.forward();
    } else {
      _flipController.reverse();
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
                        child: isFront ? _buildFrontCard() : _buildBackCard(),
                      );
                    },
                  ),
                ),
              ),
            ),
            if (_isFlipped)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: Row(
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
                child: Text('اضغط للكشف عن المعنى', style: TextStyle(color: Colors.white54)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrontCard() {
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

  Widget _buildBackCard() {
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
    // إصلاح التحذير رقم 3: استخدام withAlpha بدلاً من withOpacity المتقادمة
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withAlpha(51), // 51 يعادل 20% شفافية تقريباً
        foregroundColor: color,
        elevation: 0,
        minimumSize: const Size(70, 56), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () {
        handleCardRating(null, 'test_card_1', rating, false);
        _toggleFlip(); 
      },
      child: Text(label, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
    );
  }
}
