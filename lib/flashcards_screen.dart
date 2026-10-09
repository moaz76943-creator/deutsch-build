import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'repositories/vocabulary_repository.dart';
import 'core/srs_engine.dart';
import 'core/design/bidi_text_isolator.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  final VocabularyRepository _repo = VocabularyRepository();
  final FlutterTts _tts = FlutterTts();
  final PageController _pageController = PageController();

  List<Map<String, dynamic>> vocabulary = [];
  bool isLoading = true;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadOfflineFirst();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('de-DE');
    await _tts.setSpeechRate(0.42);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> _speak(String word) async {
    if (word.trim().isNotEmpty) {
      await HapticFeedback.lightImpact();
      await _tts.stop();
      await _tts.speak(word);
    }
  }

  Color _getArticleColor(String article) {
    switch (article.toLowerCase().trim()) {
      case 'der':
        return const Color(0xFF1E88E5);
      case 'die':
        return const Color(0xFFE53935);
      case 'das':
        return const Color(0xFF43A047);
      default:
        return const Color(0xFF5C6BC0);
    }
  }

  Future<void> _loadOfflineFirst() async {
    final localItems = await _repo.getVocabularyList();
    if (localItems.isNotEmpty) {
      if (mounted) {
        setState(() {
          vocabulary = List<Map<String, dynamic>>.from(localItems);
          isLoading = false;
        });
        _speakCurrentWord();
      }
    }

    _syncFromCdnInBackground();
  }

  Future<void> _syncFromCdnInBackground() async {
    const url = 'https://cdn.jsdelivr.net/gh/moaz76943-creator/-offline-packs-store@main/packs/de_vocab_a1.pack.gz';
    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decodedData = gzip.decode(response.bodyBytes);
        final jsonString = utf8.decode(decodedData);
        final dynamic decodedJson = json.decode(jsonString);

        if (decodedJson is Map<String, dynamic> && decodedJson['items'] is List) {
          final List<Map<String, dynamic>> fetched = (decodedJson['items'] as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();

          if (fetched.isNotEmpty) {
            await _repo.saveVocabularyList(fetched);
            if (mounted) {
              setState(() {
                vocabulary = fetched;
                isLoading = false;
              });
            }
          }
        }
      }
    } catch (_) {
      // الاستمرار في العمل دون انقطاع بالبيانات المحلية
    } finally {
      if (mounted && isLoading) {
        setState(() => isLoading = false);
      }
    }
  }

  void _speakCurrentWord() {
    if (vocabulary.isNotEmpty && currentIndex < vocabulary.length) {
      final word = vocabulary[currentIndex]['word']?.toString() ?? '';
      _speak(word);
    }
  }

  Future<void> _rateCurrentWord(ReviewRating rating) async {
    if (vocabulary.isEmpty || currentIndex >= vocabulary.length) return;

    final item = vocabulary[currentIndex];
    final word = item['word']?.toString() ?? '';
    if (word.isNotEmpty) {
      await SrsEngine.processReview(word, rating);
    }

    await HapticFeedback.mediumImpact();

    if (currentIndex < vocabulary.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Widget _buildRatingButton({
    required String label,
    required Color color,
    required ReviewRating rating,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () => _rateCurrentWord(rating),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && vocabulary.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (vocabulary.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inbox_rounded, size: 70, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('لا توجد مفردات متاحة حالياً', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadOfflineFirst,
                icon: const Icon(Icons.refresh),
                label: const Text('تحديث'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${currentIndex + 1} / ${vocabulary.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded, size: 28),
                    color: Colors.indigo,
                    onPressed: _speakCurrentWord,
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.horizontal,
                itemCount: vocabulary.length,
                onPageChanged: (index) {
                  setState(() => currentIndex = index);
                  HapticFeedback.selectionClick();
                  _speakCurrentWord();
                },
                itemBuilder: (context, index) {
                  final item = vocabulary[index];
                  final String word = item['word']?.toString() ?? '';
                  final String article = item['article']?.toString() ?? '';
                  final String meaning = item['meaning']?.toString() ?? '';
                  final String imageName = item['image']?.toString() ?? '';
                  final String imageUrl =
                      'https://cdn.jsdelivr.net/gh/moaz76943-creator/-offline-packs-store@main/images/$imageName';
                  final Color themeColor = _getArticleColor(article);

                  return _FlipCardItem(
                    key: ValueKey(word),
                    word: word,
                    article: article,
                    meaning: meaning,
                    imageUrl: imageUrl,
                    themeColor: themeColor,
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  _buildRatingButton(
                    label: 'إعادة',
                    color: const Color(0xFFEF4444),
                    rating: ReviewRating.again,
                  ),
                  _buildRatingButton(
                    label: 'صعب',
                    color: const Color(0xFFF59E0B),
                    rating: ReviewRating.hard,
                  ),
                  _buildRatingButton(
                    label: 'جيد',
                    color: const Color(0xFF3B82F6),
                    rating: ReviewRating.good,
                  ),
                  _buildRatingButton(
                    label: 'سهل',
                    color: const Color(0xFF10B981),
                    rating: ReviewRating.easy,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlipCardItem extends StatefulWidget {
  final String word;
  final String article;
  final String meaning;
  final String imageUrl;
  final Color themeColor;

  const _FlipCardItem({
    super.key,
    required this.word,
    required this.article,
    required this.meaning,
    required this.imageUrl,
    required this.themeColor,
  });

  @override
  State<_FlipCardItem> createState() => _FlipCardItemState();
}

class _FlipCardItemState extends State<_FlipCardItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    HapticFeedback.lightImpact();
    if (_controller.isAnimating) return;
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _isFront = !_isFront);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: _flipCard,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final double angle = _animation.value * math.pi;
            final bool isUnder = angle > (math.pi / 2);

            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateY(angle),
              alignment: Alignment.center,
              child: isUnder
                  ? Transform(
                      transform: Matrix4.identity()..rotateY(math.pi),
                      alignment: Alignment.center,
                      child: _buildBackCard(context),
                    )
                  : _buildFrontCard(context),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFrontCard(BuildContext context) {
    final String isolatedWord = BiDiTextIsolator.isolateGerman(widget.word);

    return Card(
      elevation: 7,
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: widget.themeColor.withValues(alpha: 0.35), width: 2),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.90,
        height: MediaQuery.of(context).size.height * 0.65,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.article.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.themeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.article.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            const SizedBox(height: 14),
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  memCacheWidth: 600,
                  memCacheHeight: 600,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.broken_image, size: 70, color: Colors.grey),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 18),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                isolatedWord,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app_outlined, size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  'المس لاكتشاف المعنى',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackCard(BuildContext context) {
    final String isolatedWord = BiDiTextIsolator.isolateGerman(widget.word);
    final String isolatedMeaning = BiDiTextIsolator.isolateArabic(widget.meaning);
    final String headerText = widget.article.isNotEmpty
        ? '${widget.article.toUpperCase()} $isolatedWord'
        : isolatedWord;

    return Card(
      elevation: 7,
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: widget.themeColor, width: 2),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.90,
        height: MediaQuery.of(context).size.height * 0.65,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: widget.themeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                headerText,
                style: TextStyle(
                  color: widget.themeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const Spacer(),
            const Icon(Icons.translate_rounded, size: 48, color: Color(0xFF64748B)),
            const SizedBox(height: 16),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                isolatedMeaning,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flip_to_front_rounded, size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  'المس للعودة إلى الكلمة',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
