import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/hybrid_audio_service.dart';
import '../core/srs/review_command_port.dart';
import '../providers/active_language_provider.dart';
import '../services/database_service.dart';
import '../widgets/bidi_lexicon_view.dart';
import '../widgets/lexicon_rich_details.dart';
import '../widgets/language_selector_button.dart';
import '../widgets/phonetic_ipa_view.dart';
import '../widgets/resilient_text_container.dart';
import 'word_deep_dive_sheet.dart' show WordDeepDiveSheet;

/// Review only scheduled-due cards and never-reviewed content entries.
Future<List<Map<String, dynamic>>> loadFlashcardsSafe(
  String targetLangCode,
) => DatabaseService.instance.loadDueFlashcards(targetLangCode);

class FlashcardsScreen extends ConsumerStatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;
  final HybridAudioService _audio = HybridAudioService();

  List<Map<String, dynamic>> _cards = <Map<String, dynamic>>[];
  String _languageCode = 'de';
  int _cardIndex = 0;
  int _completedCount = 0;
  int _loadGeneration = 0;
  bool _isLoading = false;
  bool _hasStarted = false;
  bool _restoringLanguage = false;
  bool _isFlipped = false;
  bool _isSubmitting = false;
  ReviewRating? _failedRating;
  String? _error;

  Map<String, dynamic>? get _currentCard =>
      _cards.isEmpty ? null : _cards[_cardIndex];

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
    _loadGeneration++;
    _flipController.dispose();
    unawaited(_audio.dispose());
    super.dispose();
  }

  Future<void> _beginReview() async {
    if (_hasStarted) return;
    setState(() {
      _hasStarted = true;
      _isLoading = true;
    });
    _restoringLanguage = true;
    try {
      await ref
          .read(activeLanguageProvider.notifier)
          .initialize(refreshRemoteCatalog: false);
    } catch (_) {
      // The bundled German language remains the safe offline fallback.
    } finally {
      _restoringLanguage = false;
    }
    if (!mounted) return;
    await _loadCards(ref.read(activeLanguageCodeProvider));
  }

  Future<void> _loadCards(String languageCode) async {
    unawaited(_audio.stop());
    final generation = ++_loadGeneration;
    if (!mounted) return;
    setState(() {
      _languageCode = languageCode;
      _isLoading = true;
      _completedCount = 0;
      _isFlipped = false;
      _failedRating = null;
      _error = null;
    });
    _flipController.reset();
    try {
      final cards = await loadFlashcardsSafe(languageCode);
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _cards = cards;
        _cardIndex = 0;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _cards = <Map<String, dynamic>>[];
        _cardIndex = 0;
        _isLoading = false;
        _error = 'حزمة هذه اللغة غير متاحة للمراجعة.';
      });
    }
  }

  static Map<String, dynamic> _fields(Map<String, dynamic> row) {
    if (row['fields'] is Map) {
      return Map<String, dynamic>.from(row['fields'] as Map);
    }
    final raw = row['fields_json'];
    if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return <String, dynamic>{};
  }

  static String _string(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return '';
  }

  String get _headword {
    final card = _currentCard;
    if (card == null) return '';
    return _string(card, <String>['lemma', 'surface', 'display_text']);
  }

  void _toggleFlip() {
    if (_isSubmitting || _currentCard == null) return;
    setState(() => _isFlipped = !_isFlipped);
    if (_isFlipped) {
      _flipController.forward();
      if (_headword.isNotEmpty) {
        unawaited(_playCardAudio());
      }
    } else {
      _flipController.reverse();
    }
  }


  Future<void> _playCardAudio() async {
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

  Future<void> _handleRating(ReviewRating rating) async {
    if (_isSubmitting || _cards.isEmpty) return;
    final card = _currentCard;
    if (card == null) return;

    final generation = _loadGeneration;
    final languageCode = _languageCode;
    final lexemeId =
        (card['lexeme_id'] ?? card['id'])?.toString().trim() ?? '';
    final grade = switch (rating) {
      ReviewRating.again => 0,
      ReviewRating.hard => 2,
      ReviewRating.good => 3,
      ReviewRating.easy => 4,
    };

    setState(() {
      _isSubmitting = true;
      _failedRating = null;
    });
    try {
      if (lexemeId.isEmpty) {
        throw StateError('Cannot persist a review without a lexeme ID');
      }
      await DatabaseService.instance.gradeAndPersistSrs(
        lexemeId: lexemeId,
        languageCode: languageCode,
        grade: grade,
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          if (generation == _loadGeneration) _failedRating = rating;
          _isSubmitting = false;
        });
      }
      return; // The current card is retained for an explicit retry.
    }

    // The card may advance only after the transaction has committed.
    if (!mounted) return;
    if (generation != _loadGeneration) {
      setState(() => _isSubmitting = false);
      return;
    }
    try {
      await _flipController.reverse();
    } catch (_) {
      // The review is already persisted; animation failure must not regrade it.
    }
    if (!mounted) return;
    setState(() {
      if (generation == _loadGeneration) {
        // A successfully graded card is not due again in this session.
        _cards = List<Map<String, dynamic>>.from(_cards)
          ..removeAt(_cardIndex);
        _cardIndex = _cards.isEmpty ? 0 : _cardIndex % _cards.length;
        _completedCount++;
        _isFlipped = false;
      }
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String>(activeLanguageCodeProvider, (previous, next) {
      if (_hasStarted && !_restoringLanguage &&
          next != previous && next != _languageCode) {
        unawaited(_loadCards(next));
      }
    });
    final totalReviews = _completedCount + _cards.length;
    final progress = totalReviews == 0 ? 0.0 : _completedCount / totalReviews;

    return Scaffold(
      appBar: AppBar(
        title: const Text('مراجعة اليوم', style: TextStyle(fontFamily: 'Cairo')),
        actions: const <Widget>[LanguageSelectorButton()],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white24,
              ),
            ),
            Expanded(
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
                          child: Text(_error ?? (_completedCount > 0
                              ? 'اكتملت مراجعات اليوم.'
                              : 'لا توجد بطاقات مستحقة للمراجعة اليوم.')),
                        )
                      : GestureDetector(
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
            if (_cards.isNotEmpty && _isFlipped)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: _isSubmitting
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
                              onPressed: () => _handleRating(_failedRating!),
                              icon: const Icon(Icons.refresh),
                              label: const Text('إعادة المحاولة'),
                            ),
                          ],
                          Wrap(
                             alignment: WrapAlignment.center,
                             spacing: 6,
                             runSpacing: 8,
                            children: <Widget>[
                              _ratingButton('مجدداً', Colors.redAccent, ReviewRating.again),
                              _ratingButton('صعب', Colors.orangeAccent, ReviewRating.hard),
                              _ratingButton('جيد', Colors.blueAccent, ReviewRating.good),
                              _ratingButton('سهل', Colors.green, ReviewRating.easy),
                            ],
                          ),
                        ],
                      ),
              )
            else if (_cards.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Text('اضغط للكشف والاستماع', style: TextStyle(color: Colors.white54)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrontCard() {
    final card = _currentCard!;
    final fields = _fields(card);
    final ipa = _string(<String, dynamic>{...fields, ...card},
        <String>['ipa', 'phonetic_ipa', 'ipa_transcription']);
    return Container(
      width: double.infinity,
      height: 400,
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ResilientTextContainer(
              text: _headword,
              maxLines: 6,
              textDirection: isRtlLanguage(_languageCode)
                  ? TextDirection.rtl : TextDirection.ltr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (ipa.isNotEmpty) ...<Widget>[
              const SizedBox(height: 14),
              PhoneticIpaView(ipa: ipa),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBackCard() {
    final card = _currentCard!;
    final fields = _fields(card);
    final translation = _string(<String, dynamic>{...fields, ...card},
        <String>['meaning', 'translation_ar', 'translation', 'definition_ar']);
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateX(pi),
      child: Container(
        width: double.infinity,
        height: 400,
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF334155),
          borderRadius: BorderRadius.circular(24),
        ),
        // All optional sections scroll rather than overflowing a flipped card.
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (translation.isNotEmpty) ...<Widget>[
                ResilientTextContainer(
                  text: translation,
                  maxLines: 8,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, color: Colors.white),
                ),
                const SizedBox(height: 12),
              ],
              LexiconRichDetails(
                entry: card,
                languageCode: _languageCode,
                showMeaning: translation.isEmpty,
              ),
              TextButton.icon(
                onPressed: () => WordDeepDiveSheet.show(
                  context,
                  wordData: card,
                ),
                icon: const Icon(Icons.info_outline),
                label: const Text('تفاصيل المفردة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ratingButton(String label, Color color, ReviewRating rating) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withAlpha(51),
        foregroundColor: color,
        minimumSize: const Size(70, 56),
      ),
      onPressed: () => _handleRating(rating),
      child: Text(
        label,
        style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
      ),
    );
  }
}
