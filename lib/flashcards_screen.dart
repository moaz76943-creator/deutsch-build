import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/srs_engine.dart';
import 'core/audio/offline_audio_pool.dart';
import 'services/language_pack_manager.dart';

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
  final PageController _pageController = PageController();
  final OfflineAudioPool _audioPool = OfflineAudioPool();

  List<Map<String, dynamic>> _vocabulary = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _zenMode = false;

  @override
  void initState() {
    super.initState();
    _loadVocabulary();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadVocabulary() async {
    setState(() => _isLoading = true);
    try {
      if (widget.initialVocab != null && widget.initialVocab!.isNotEmpty) {
        _vocabulary = List<Map<String, dynamic>>.from(widget.initialVocab!);
      } else {
        final pack = await LanguagePackManager.loadPack(widget.languageCode);
        _vocabulary = List<Map<String, dynamic>>.from(pack);
      }
    } catch (_) {
      _vocabulary = [
        {
          'word': 'Hallo',
          'article': 'das',
          'meaning': 'مرحباً',
          'example': 'Hallo, wie geht es dir?',
          'exampleMeaning': 'مرحباً، كيف حالك؟',
          'category': 'A1'
        }
      ];
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _speakCurrentWord() {
    if (_vocabulary.isEmpty) return;
    final word = _vocabulary[_currentIndex]['word'] ?? '';
    _audioPool.playWord(
      word,
      locale: LanguagePackManager.getTtsLocale(widget.languageCode),
    );
  }

  void _onFlipCard() {
    HapticFeedback.selectionClick();
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  void _onRate(ReviewRating rating) {
    HapticFeedback.lightImpact();
    SrsEngine.processReview(
      _vocabulary[_currentIndex],
      rating,
      widget.languageCode,
    );

    if (_currentIndex < _vocabulary.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 أحسنت! أكملت مراجعة جميع بطاقات هذه الجلسة.'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  Color _getArticleColor(String? article) {
    switch (article?.toLowerCase()) {
      case 'der':
        return Colors.blue.shade600;
      case 'die':
        return Colors.red.shade500;
      case 'das':
        return Colors.green.shade600;
      default:
        return const Color(0xFF4F46E5);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_vocabulary.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('بطاقات المراجعة')),
        body: const Center(child: Text('لا توجد كلمات متاحة حالياً.')),
      );
    }

    final item = _vocabulary[_currentIndex];
    final word = item['word'] ?? '';
    final article = item['article'] ?? '';
    final meaning = item['meaning'] ?? '';
    final example = item['example'] ?? '';
    final exampleMeaning = item['exampleMeaning'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('بطاقات (${_currentIndex + 1}/${_vocabulary.length})'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_zenMode ? Icons.self_improvement : Icons.self_improvement_outlined),
            tooltip: 'وضع التركيز الهادئ (Zen Mode)',
            onPressed: () => setState(() => _zenMode = !_zenMode),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up_rounded),
            onPressed: _speakCurrentWord,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: GestureDetector(
                  onTap: _onFlipCard,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        )
                      ],
                      border: Border.all(
                        color: _getArticleColor(article).withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (article.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getArticleColor(article).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              article,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _getArticleColor(article),
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        Text(
                          word,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (_isFlipped) ...[
                          const Divider(height: 32),
                          Text(
                            meaning,
                            style: const TextStyle(
                              fontSize: 22,
                              color: Color(0xFF4F46E5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (example.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              example,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                          if (exampleMeaning.isNotEmpty)
                            Text(
                              exampleMeaning,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            ),
                        ] else ...[
                          const SizedBox(height: 24),
                          Text(
                            'المس البطاقة لإظهار المعنى',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildRateBtn('إعادة', ReviewRating.again, Colors.red.shade400),
                  const SizedBox(width: 8),
                  _buildRateBtn('صعب', ReviewRating.hard, Colors.orange.shade400),
                  const SizedBox(width: 8),
                  _buildRateBtn('جيد', ReviewRating.good, Colors.blue.shade400),
                  const SizedBox(width: 8),
                  _buildRateBtn('سهل', ReviewRating.easy, Colors.green.shade500),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildRateBtn(String label, ReviewRating rating, Color color) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () => _onRate(rating),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
