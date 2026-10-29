import 'package:flutter/material.dart';
import 'dart:math';
import '../core/srs/review_command_port.dart';
<<<<<<< HEAD
import '../services/database_service.dart';
import '../widgets/lexicon_rich_details.dart';
import '../widgets/language_selector_button.dart';
import '../widgets/phonetic_ipa_view.dart';
import '../widgets/resilient_text_container.dart';
import 'word_deep_dive_sheet.dart' show WordDeepDiveSheet;

/// Review only scheduled-due cards and never-reviewed content entries.
Future<List<Map<String, dynamic>>> loadFlashcardsSafe(
  String targetLangCode,
) =>
    DatabaseService.instance.loadDueFlashcards(targetLangCode);

class FlashcardsScreen extends ConsumerStatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
=======
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
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
}

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});
  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> with SingleTickerProviderStateMixin {
  late AnimationController flipController;
  late Animation<double> flipAnimation;
  bool isFlipped = false;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    flipAnimation = Tween<double>(begin: 0, end: 1).animate(flipController);
  }

  @override
  void dispose() {
    flipController.dispose();
    OfflineAudioManager.instance.stop();
    super.dispose();
  }

  void toggleFlip() {
    if (isSubmitting) return;
    setState(() {
      isFlipped = !isFlipped;
    });
    if (isFlipped) {
      flipController.forward();
      OfflineAudioManager.instance.speak("das Buch");
    } else {
      flipController.reverse();
    }
  }

<<<<<<< HEAD
  Future<void> playCardAudio() async {
    final card = _currentCard;
    if (card == null) return;
    final fields = _fields(card);
    final ipa = _string(<String, dynamic>{...fields, ...card},
        <String>['ipa', 'phonetic_ipa', 'ipa_transcription']);
    await _audio.playAudio(
      text: _headword,
      languageCode: _languageCode,
      ipa: ipa.isEmpty ? null : ipa,
      context: context,
    );
  }

=======
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
  Future<void> handleRating(ReviewRating rating) async {
    if (isSubmitting) return;
    setState(() => isSubmitting = true);

<<<<<<< HEAD
    final generation = _loadGeneration;
    final languageCode = _languageCode;
    final lexemeId = (card['lexeme_id'] ?? card['id'])?.toString().trim() ?? '';
    final grade = switch (rating) {
      ReviewRating.again => 0,
      ReviewRating.hard => 2,
      ReviewRating.good => 3,
      ReviewRating.easy => 4,
    };
=======
    await Future.delayed(const Duration(milliseconds: 300));
>>>>>>> origin/staging/v2-full-platform-1792367411258400957

    if (mounted) {
      setState(() {
        isSubmitting = false;
        toggleFlip();
      });
    }
<<<<<<< HEAD

    // The card may advance only after the transaction has committed.
    if (!mounted) return;
    if (generation != _loadGeneration) {
      setState(() => isSubmitting = false);
      return;
    }
    try {
      await flipController.reverse();
    } catch (_) {
      // The review is already persisted; animation failure must not regrade it.
    }
    if (!mounted) return;
    setState(() {
      if (generation == _loadGeneration) {
        // A successfully graded card is not due again in this session.
        _cards = List<Map<String, dynamic>>.from(_cards)..removeAt(_cardIndex);
        _cardIndex = _cards.isEmpty ? 0 : _cardIndex % _cards.length;
        _completedCount++;
        isFlipped = false;
      }
      isSubmitting = false;
    });
=======
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    ref.listen<String>(activeLanguageCodeProvider, (previous, next) {
      if (_hasStarted &&
          !_restoringLanguage &&
          next != previous &&
          next != _languageCode) {
        unawaited(_loadCards(next));
      }
    });
    final totalReviews = _completedCount + _cards.length;
    final progress = totalReviews == 0 ? 0.0 : _completedCount / totalReviews;

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('مراجعة اليوم', style: TextStyle(fontFamily: 'Cairo')),
        actions: const <Widget>[LanguageSelectorButton()],
=======
    return Scaffold(
      appBar: AppBar(
        title: const Text('مراجعة اليوم', style: TextStyle(fontFamily: 'Cairo')),
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
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
<<<<<<< HEAD
              child: !_hasStarted
                  ? Center(
                      child: ElevatedButton.icon(
                        onPressed: _beginReview,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('ابدأ المراجعة'),
                      ),
                    )
                  : _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _cards.isEmpty
                          ? Center(
                              child: Text(_error ??
                                  (_completedCount > 0
                                      ? 'اكتملت مراجعات اليوم.'
                                      : 'لا توجد بطاقات مستحقة للمراجعة اليوم.')),
                            )
                          : GestureDetector(
                              onTap: toggleFlip,
                              child: Center(
                                child: AnimatedBuilder(
                                  animation: flipAnimation,
                                  builder: (context, child) {
                                    final angle = flipAnimation.value * pi;
                                    final isFront = angle < pi / 2;
                                    return Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()
                                        ..setEntry(3, 2, 0.001)
                                        ..rotateX(angle),
                                      child: isFront
                                          ? _buildFrontCard()
                                          : _buildBackCard(),
                                    );
                                  },
                                ),
                              ),
                            ),
=======
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
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
            ),
            if (isFlipped)
              Padding(
<<<<<<< HEAD
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: isSubmitting
                    ? const CircularProgressIndicator()
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (_failedRating != null) ...<Widget>[
                            const Text(
                              'تعذّر حفظ التقييم. لم يتم الانتقال إلى البطاقة التالية.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.redAccent),
                            ),
                            TextButton.icon(
                              onPressed: () => handleRating(_failedRating!),
                              icon: const Icon(Icons.refresh),
                              label: const Text('إعادة المحاولة'),
                            ),
                          ],
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 6,
                            runSpacing: 8,
                            children: <Widget>[
                              _ratingButton('مجدداً', Colors.redAccent,
                                  ReviewRating.again),
                              _ratingButton('صعب', Colors.orangeAccent,
                                  ReviewRating.hard),
                              _ratingButton(
                                  'جيد', Colors.blueAccent, ReviewRating.good),
                              _ratingButton(
                                  'سهل', Colors.green, ReviewRating.easy),
                            ],
                          ),
                        ],
                      ),
=======
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
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
              )
            else
              const Padding(
<<<<<<< HEAD
                padding: EdgeInsets.all(40),
                child: Text('اضغط للكشف والاستماع',
                    style: TextStyle(color: Colors.white54)),
=======
                padding: EdgeInsets.all(40.0),
                child: Text('اضغط للكشف والاستماع', style: TextStyle(color: Colors.white54)),
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
              ),
          ],
        ),
      ),
    );
  }

  Widget buildFrontAppBaseGlassCard() {
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

  Widget buildBackAppBaseGlassCard() {
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
<<<<<<< HEAD
          children: <Widget>[
            ResilientTextContainer(
              text: _headword,
              maxLines: 6,
              textDirection: isRtlLanguage(_languageCode)
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (ipa.isNotEmpty) ...<Widget>[
              SizedBox(height: 14),
              PhoneticIpaView(ipa: ipa),
            ],
=======
          children: [
            Text('الكتاب', style: TextStyle(fontSize: 32, fontFamily: 'Cairo', color: Colors.white)),
            SizedBox(height: 20),
            Text('Ich lese ein Buch.', style: TextStyle(fontSize: 18, color: Colors.white70)),
            Text('أنا أقرأ كتاباً.', style: TextStyle(fontSize: 18, fontFamily: 'Cairo', color: Colors.white70)),
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
          ],
        ),
      ),
    );
  }

  Widget buildRatingButton(String label, Color color, ReviewRating rating) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withAlpha(51),
        foregroundColor: color,
        elevation: 0,
        minimumSize: const Size(70, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () => handleRating(rating),
<<<<<<< HEAD
      child: Text(
        label,
        style:
            const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
      ),
=======
      child: Text(label, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
    );
  }
}
