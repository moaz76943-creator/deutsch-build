import 'package:flutter/material.dart';
import 'dart:math';
import '../widgets/language_selector_button.dart';
import '../core/srs/review_command_port.dart';
import '../core/audio/offline_audio_manager.dart';
import '../services/local_database_service.dart';
import '../services/database_service.dart';
import '../services/fts_search_service.dart';
import '../widgets/lexicon_rich_details.dart';

Future<List<Map<String, dynamic>>> loadFlashcardsSafe(String targetLangCode) async {
  final db = await LocalDatabaseService.instance.getContentDb(targetLangCode);
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

class _FlashcardsScreenState extends State<FlashcardsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;
  final FtsSearchService _searchService = FtsSearchService();

  List<Map<String, dynamic>> _cards = <Map<String, dynamic>>[];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isFlipped = false;
  bool _isSubmitting = false;

  Map<String, dynamic> get _currentCard => _cards[_currentIndex];

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _flipAnimation =
        Tween<double>(begin: 0, end: 1).animate(_flipController);
    _loadCards();
  }

  Future<void> _loadCards() async {
    try {
      final List<Map<String, dynamic>> cards;
      try {
        cards = await _searchService.searchDictionary('', 'de', limit: 20);
      } catch (_) {
        cards = await DatabaseService.instance.searchDictionary('', 'de');
      }
      if (!mounted) return;
      setState(() {
        _cards = cards;
        _currentIndex = 0;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      debugPrint('Offline flashcard loading failed: $error');
      setState(() {
        _cards = <Map<String, dynamic>>[];
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    OfflineAudioManager.instance.stop();
    super.dispose();
  }

  void _toggleFlip() {
    if (_isSubmitting || _cards.isEmpty) return;
    setState(() => _isFlipped = !_isFlipped);
    if (_isFlipped) {
      _flipController.forward();
      final headword = LexiconRichDetails.headword(_currentCard);
      if (headword.isNotEmpty) {
        OfflineAudioManager.instance.speak(headword);
      }
    } else {
      _flipController.reverse();
    }
  }

  Future<void> _handleRating(ReviewRating rating) async {
    if (_isSubmitting || _cards.isEmpty) return;
    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _flipController.reset();
    setState(() {
      _isSubmitting = false;
      _isFlipped = false;
      _currentIndex = (_currentIndex + 1) % _cards.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'مراجعة اليوم',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        actions: const <Widget>[LanguageSelectorButton()],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _cards.isEmpty
                ? const Center(child: Text('لا توجد بطاقات متاحة دون اتصال'))
                : Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: LinearProgressIndicator(
                          value: (_currentIndex + 1) / _cards.length,
                          backgroundColor: Colors.white24,
                        ),
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
                                  child: isFront
                                      ? _buildFrontCard()
                                      : _buildBackCard(),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      if (_isFlipped)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 24,
                          ),
                          child: _isSubmitting
                              ? const CircularProgressIndicator()
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    _buildRatingButton('مجدداً',
                                        Colors.redAccent, ReviewRating.again),
                                    _buildRatingButton('صعب',
                                        Colors.orangeAccent, ReviewRating.hard),
                                    _buildRatingButton('جيد',
                                        Colors.blueAccent, ReviewRating.good),
                                    _buildRatingButton('سهل',
                                        Colors.green, ReviewRating.easy),
                                  ],
                                ),
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.all(40),
                          child: Text(
                            'اضغط للكشف والاستماع',
                            style: TextStyle(color: Colors.white54),
                          ),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: SingleChildScrollView(
          child: LexiconRichDetails(
            entry: _currentCard,
            showMeaning: false,
            showExamples: false,
            showIdioms: false,
          ),
        ),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF334155),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: LexiconRichDetails(entry: _currentCard),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: () => _handleRating(rating),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
