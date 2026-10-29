import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import '../services/database_service.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  bool _showBack = false;
  int _currentIndex = 0;
  List<Map<String, dynamic>> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() => _isLoading = true);
    try {
      final contentDb = await DatabaseService.instance.contentDb;
      // جلب 10 كلمات للدراسة مع أمثلتها
      final results = await contentDb.rawQuery('''
        SELECT l.lexeme_id, l.article, l.lemma, l.plural, 
               e.translation_ar, e.sentence
        FROM lexemes l
        LEFT JOIN examples e ON e.concept_id = l.concept_id AND e.language_code = l.language_code
        WHERE l.language_code = 'de'
        LIMIT 10
      ''');

      setState(() {
        _cards = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleReview(bool isEasy) async {
    if (_cards.isEmpty || _currentIndex >= _cards.length) return;
    
    final card = _cards[_currentIndex];
    final progressDb = await DatabaseService.instance.progressDb;
    
    // تسجيل قرار المستخدم في قاعدة التقدم المستقلة
    await progressDb.rawInsert('''
      INSERT OR REPLACE INTO srs_progress (lexeme_id, target_language_code, repetition_count, status)
      VALUES (?, 'de', 
        COALESCE((SELECT repetition_count + 1 FROM srs_progress WHERE lexeme_id = ?), 1),
        ?
      )
    ''', [card['lexeme_id'], card['lexeme_id'], isEasy ? 'review' : 'learning']);

    setState(() {
      _showBack = false;
      _currentIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B1F4D),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8))),
      );
    }

    if (_currentIndex >= _cards.length || _cards.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B1F4D),
        appBar: AppBar(title: const Text('بطاقات المفردات'), backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 72),
              const SizedBox(height: 16),
              Text('أنهيت مراجعة اليوم!', style: AppTypography.display.copyWith(color: Colors.white, fontSize: 24)),
              const SizedBox(height: 8),
              Text('تم حفظ تقدمك بنجاح', style: AppTypography.body.copyWith(color: Colors.white70)),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('العودة للرئيسية'),
              ),
            ],
          ),
        ),
      );
    }

    final card = _cards[_currentIndex];
    final article = card['article'] ?? '';
    final german = card['lemma'] ?? '';
    final plural = card['plural'] ?? '-';
    final arabic = card['translation_ar'] ?? 'بدون ترجمة';
    final example = card['sentence'] ?? 'بدون مثال';

    return Scaffold(
      appBar: AppBar(
        title: const Text('بطاقات المفردات (SRS)'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Column(
              children: <Widget>[
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / _cards.length,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 12),
                Text(
                  'بطاقة ${_currentIndex + 1} من ${_cards.length}',
                  style: AppTypography.body.copyWith(color: Colors.white.withValues(alpha: 0.7)),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _showBack = !_showBack),
                  child: AppBaseGlassCard(
                    padding: const EdgeInsets.all(32),
                    gradient: AppGradients.blueCard,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (!_showBack) ...<Widget>[
                          if (article.toString().isNotEmpty)
                            ArticleBadge(article: article.toString(), label: article.toString()),
                          const SizedBox(height: 20),
                          Text(
                            german.toString(),
                            style: AppTypography.display.copyWith(color: Colors.white, fontSize: 34),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'الجمع: $plural',
                            style: AppTypography.body.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'المس للقلب ومعرفة المعنى',
                            style: AppTypography.body.copyWith(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                          ),
                        ] else ...<Widget>[
                          Text(
                            arabic.toString(),
                            style: AppTypography.display.copyWith(color: const Color(0xFF38BDF8), fontSize: 32),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              example.toString(),
                              style: AppTypography.body.copyWith(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _handleReview(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          side: const BorderSide(color: Color(0xFFEF4444)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('صعبة (إعادة قريباً)'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleReview(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('سهلة (حفظ)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
