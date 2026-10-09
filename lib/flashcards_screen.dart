import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'repositories/vocabulary_repository.dart';
import 'core/srs_engine.dart';
import 'core/design/bidi_text_isolator.dart';
import 'services/language_pack_manager.dart';

as http;

class FlashcardsScreen extends StatefulWidget {
  final List<dynamic>? initialVocab;
  final String langCode;
  String get languageCode => langCode;

  const FlashcardsScreen({
    super.key,
    this.initialVocab,
    String? langCode,
    String? languageCode,
  }) : langCode = languageCode ?? langCode ?? 'de';

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
    _loadVocabulary();
  }

  Future<void> _initTts() async {
    final String locale = LanguagePackManager.getTtsLocale(widget.langCode);
    await _tts.setLanguage(locale);
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
      case 'el':
      case 'il':
      case 'le':
        return const Color(0xFF1E88E5);
      case 'die':
      case 'la':
        return const Color(0xFFE53935);
      case 'das':
      case 'lo':
        return const Color(0xFF43A047);
      default:
        return const Color(0xFF6366F1);
    }
  }

  Future<void> _loadVocabulary() async {
    // 1. إذا تم تمرير كلمات محددة من الشاشة الرئيسية، استخدمها فوراً
    if (widget.initialVocab != null && widget.initialVocab!.isNotEmpty) {
      if (mounted) {
        setState(() {
          vocabulary = List<Map<String, dynamic>>.from(widget.initialVocab!);
          isLoading = false;
        });
        _speakCurrentWord();
      }
      return;
    }

    // 2. إذا كانت اللغة غير الألمانية، حمّل حزمتها مباشرة من مدير اللغات
    if (widget.langCode != 'de') {
      final items = await LanguagePackManager.loadPack(widget.langCode);
      if (mounted) {
        setState(() {
          vocabulary = items;
          isLoading = false;
        });
        _speakCurrentWord();
      }
      return;
    }

    // 3. في حالة الألمانية: استراتيجية Offline-First المحلية والمزامنة
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
      // استمرار العمل بالبيانات المحلية تلقائياً
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(color: Colors.black87),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inbox_rounded, size: 70, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'لا توجد مفردات حالياً لقسم (${LanguagePackManager.getLanguageName(widget.langCode)})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadVocabulary,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          LanguagePackManager.getLanguageName(widget.langCode),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${currentIndex + 1} / ${vocabulary.length}',
                    style: const TextStyle(
                      fontSize: 17,
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
                  final String example = item['example']?.toString() ?? '';
                  final String exampleMeaning = item['exampleMeaning']?.toString() ?? '';
                  final String imageName = item['image']?.toString() ?? '';
                  final String imageUrl =
                      'https://cdn.jsdelivr.net/gh/moaz76943-creator/-offline-packs-store@main/images/$imageName';
                  final Color themeColor = _getArticleColor(article);

                  return _FlipCardItem(
                    key: ValueKey('${widget.langCode}_$word'),
                    word: word,
                    article: article,
                    meaning: meaning,
                    example: example,
                    exampleMeaning: exampleMeaning,
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
  final String example;
  final String exampleMeaning;
  final String imageUrl;
  final Color themeColor;

  const _FlipCardItem({
    super.key,
    required this.word,
    required this.article,
    required this.meaning,
    required this.example,
    required this.exampleMeaning,
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
                      Center(child: CircularProgressIndicator(color: widget.themeColor, strokeWidth: 2.5)),
                  errorWidget: (context, url, error) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.themeColor.withValues(alpha: 0.12),
                          widget.themeColor.withValues(alpha: 0.04),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_stories_rounded, size: 68, color: widget.themeColor),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              'مفردة تعليمية معتمدة',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: widget.themeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                  'المس لاكتشاف المعنى والسياق',
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
        padding: const EdgeInsets.all(22),
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
            const SizedBox(height: 16),
            const Icon(Icons.translate_rounded, size: 40, color: Color(0xFF64748B)),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                isolatedMeaning,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (widget.example.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.example,
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (widget.exampleMeaning.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.exampleMeaning,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ],
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
