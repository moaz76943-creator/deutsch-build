import 'dart:math' as math;

import 'package:deutsch_bilarabi/features/flashcards/learning_review_coordinator.dart';
import 'package:deutsch_bilarabi/services/database_service.dart';
import 'package:flutter/material.dart';

import '../../../core/language_bidi_helper.dart';
import '../models/wordbit_card.dart';

typedef WordBitCardLoader = Future<List<Map<String, dynamic>>> Function(
  String languageCode,
);

class WordBitCarouselScreen extends StatefulWidget {
  const WordBitCarouselScreen({
    super.key,
    this.sourceLanguageCode = 'ar',
    this.targetLanguageCode = 'de',
    this.cardLoader,
    this.reviewCoordinator,
  });

  final String sourceLanguageCode;
  final String targetLanguageCode;
  final WordBitCardLoader? cardLoader;
  final LearningReviewCoordinator? reviewCoordinator;

  @override
  State<WordBitCarouselScreen> createState() => _WordBitCarouselScreenState();
}

class _WordBitCarouselScreenState extends State<WordBitCarouselScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  final List<WordBitCard> _cards = <WordBitCard>[];
  late final LearningReviewCoordinator _reviewCoordinator;
  late final bool _ownsReviewCoordinator;
  late final String _sessionId;

  bool _isFlipped = false;
  bool _isLoading = true;
  bool _reviewInFlight = false;
  int _currentIndex = 0;
  int _loadGeneration = 0;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _sessionId = DateTime.now().toUtc().microsecondsSinceEpoch.toString();
    _ownsReviewCoordinator = widget.reviewCoordinator == null;
    _reviewCoordinator =
        widget.reviewCoordinator ?? LearningReviewCoordinator();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final generation = ++_loadGeneration;
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    final loader = widget.cardLoader ??
        (String languageCode) => DatabaseService.instance.loadDueFlashcards(
              languageCode,
              limit: 16,
            );

    try {
      final rows = await loader(widget.targetLanguageCode);
      if (!mounted || generation != _loadGeneration) {
        return;
      }
      final mapped = <WordBitCard>[];
      for (final row in rows) {
        try {
          mapped.add(
            WordBitCard.fromLexiconRow(
              row,
              sourceLanguageCode: widget.sourceLanguageCode,
            ),
          );
        } on FormatException {
          // Reject malformed rows rather than fabricating learning content.
        }
      }
      setState(() {
        _cards
          ..clear()
          ..addAll(mapped);
        _currentIndex = 0;
        _isFlipped = false;
        _isLoading = false;
        if (rows.isNotEmpty && mapped.isEmpty) {
          _loadError = 'تعذر قراءة البطاقات الموثّقة من الحزمة المحلية.';
        }
      });
    } catch (_) {
      if (!mounted || generation != _loadGeneration) {
        return;
      }
      setState(() {
        _isLoading = false;
        _loadError = 'تعذر فتح محتوى هذه اللغة دون اتصال.';
      });
    }
  }

  @override
  void dispose() {
    _loadGeneration++;
    _pageController.dispose();
    if (_ownsReviewCoordinator) {
      _reviewCoordinator.dispose();
    }
    super.dispose();
  }

  void _flipCard() {
    if (_cards.isEmpty || _reviewInFlight) {
      return;
    }
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  Future<void> _submitReview(int grade) async {
    if (_reviewInFlight || _cards.isEmpty) {
      return;
    }
    final card = _cards[_currentIndex];
    final eventId =
        'wordbit:' + _sessionId + ':' + card.id + ':' + _currentIndex.toString();

    setState(() {
      _reviewInFlight = true;
    });
    try {
      final status = await _reviewCoordinator.submit(
        eventId: eventId,
        learnerContentId: card.id,
        sourceLanguageCode: widget.sourceLanguageCode,
        targetLanguageCode: widget.targetLanguageCode,
        grade: grade,
      );
      if (!mounted) {
        return;
      }
      if (status == ReviewSubmissionStatus.accepted) {
        await _advance();
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر حفظ المراجعة محلياً. لم تُحتسب النتيجة.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _reviewInFlight = false;
        });
      }
    }
  }

  Future<void> _advance() async {
    if (_currentIndex < _cards.length - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتملت البطاقات المتاحة لهذه الجلسة.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'بطاقات ' + widget.targetLanguageCode.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return _buildFallback(
        _loadError!,
        actionLabel: 'إعادة المحاولة',
        onPressed: _loadCards,
      );
    }
    if (_cards.isEmpty) {
      return _buildFallback(
        'لا توجد بطاقات مراجعة موثّقة ومتاحة لهذه اللغة حالياً.',
        actionLabel: 'تحديث',
        onPressed: _loadCards,
      );
    }

    return Column(
      children: <Widget>[
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / _cards.length,
              minHeight: 6,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF38BDF8),
              ),
            ),
          ),
        ),
        const Spacer(),
        SizedBox(
          height: 410,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _cards.length,
            physics: _reviewInFlight
                ? const NeverScrollableScrollPhysics()
                : null,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                _isFlipped = false;
              });
            },
            itemBuilder: (context, index) {
              final card = _cards[index];
              return GestureDetector(
                onTap: _flipCard,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) {
                    final rotateAnim =
                        Tween<double>(begin: math.pi, end: 0.0).animate(animation);
                    return AnimatedBuilder(
                      animation: rotateAnim,
                      child: child,
                      builder: (context, animatedChild) {
                        final isUnder =
                            ValueKey<bool>(_isFlipped) != animatedChild?.key;
                        var tilt =
                            ((animation.value - 0.5).abs() - 0.5) * 0.002;
                        tilt = isUnder ? -tilt : tilt;
                        return Transform(
                          transform: Matrix4.rotationY(rotateAnim.value)
                            ..setEntry(3, 0, tilt),
                          alignment: Alignment.center,
                          child: animatedChild,
                        );
                      },
                    );
                  },
                  child: _isFlipped ? _buildBack(card) : _buildFront(card),
                ),
              );
            },
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: <Widget>[
              Expanded(
                child: _buildActionButton(
                  'صعب',
                  const Color(0xFFEF4444),
                  2,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'جيد',
                  const Color(0xFF3B82F6),
                  3,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'سهل',
                  const Color(0xFF10B981),
                  4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildFallback(
    String message, {
    required String actionLabel,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onPressed, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }

  Widget _buildFront(WordBitCard card) {
    final targetDir = LanguageBiDiHelper.getDirection(card.bcp47Locale);
    final targetHeight = LanguageBiDiHelper.getLineHeight(card.bcp47Locale);
    final metadata = <String>[
      if (card.article.isNotEmpty) card.article,
      if (card.partOfSpeech.isNotEmpty) card.partOfSpeech,
      if (card.plural.isNotEmpty) 'جمع: ' + card.plural,
    ];

    return Card(
      key: const ValueKey<bool>(false),
      elevation: 8,
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (metadata.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    metadata.join(' • '),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Directionality(
                textDirection: targetDir,
                child: Text(
                  card.term,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: targetHeight,
                  ),
                ),
              ),
              if (card.ipa.isNotEmpty) ...<Widget>[
                const SizedBox(height: 10),
                Text(
                  card.ipa,
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ],
              const SizedBox(height: 24),
              const Text(
                'المس البطاقة لعرض المحتوى الموثّق',
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBack(WordBitCard card) {
    final sourceLocale = card.translationLanguageCode.isNotEmpty
        ? card.translationLanguageCode
        : widget.sourceLanguageCode;
    final sourceDir = LanguageBiDiHelper.getDirection(sourceLocale);
    final sourceHeight = LanguageBiDiHelper.getLineHeight(sourceLocale);
    final targetDir = LanguageBiDiHelper.getDirection(card.bcp47Locale);

    return Card(
      key: const ValueKey<bool>(true),
      elevation: 8,
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Directionality(
                textDirection: sourceDir,
                child: Text(
                  card.translation.isEmpty
                      ? 'المعنى غير متاح في الحزمة.'
                      : card.translation,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF38BDF8),
                    height: sourceHeight,
                  ),
                ),
              ),
              if (card.exampleSentence.isNotEmpty) ...<Widget>[
                const SizedBox(height: 20),
                Divider(color: Colors.white.withAlpha(25)),
                const SizedBox(height: 12),
                Directionality(
                  textDirection: targetDir,
                  child: Text(
                    card.exampleSentence,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
              if (card.grammarNote.isNotEmpty) ...<Widget>[
                const SizedBox(height: 14),
                Directionality(
                  textDirection: targetDir,
                  child: Text(
                    card.grammarNote,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white60,
                    ),
                  ),
                ),
              ],
              if (card.semanticConceptId.isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                const Text(
                  'لا يتوفر أصل بصري معتمد لهذا المفهوم؛ العرض النصي مستخدم.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, int grade) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withAlpha(50),
        foregroundColor: color,
        side: BorderSide(color: color, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      onPressed: _reviewInFlight ? null : () => _submitReview(grade),
      child: _reviewInFlight
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }
}
