import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/language_bidi_helper.dart';

/// نموذج بيانات البطاقة المعجمية المحايد لأي زوج لغوي
class UniversalCardItem {
  final String targetWord;         // الكلمة باللغة المتعلمة
  final String targetLocale;       // كود لغة التعلم (مثال: es-ES, de-DE, zh-CN, ar-SA)
  final String sourceTranslation;  // المعنى بلغة المتعلم الأم
  final String sourceLocale;       // كود لغة المتعلم (مثال: ar-SA, en-US, fr-FR)
  final String targetExample;      // مثال باللغة المتعلمة
  final String sourceExample;      // ترجمة المثال
  final String partOfSpeech;       // التصنيف النحوي

  const UniversalCardItem({
    required this.targetWord,
    required this.targetLocale,
    required this.sourceTranslation,
    required this.sourceLocale,
    required this.targetExample,
    required this.sourceExample,
    required this.partOfSpeech,
  });
}

class WordBitCarouselScreen extends StatefulWidget {
  const WordBitCarouselScreen({super.key});

  @override
  State<WordBitCarouselScreen> createState() => _WordBitCarouselScreenState();
}

class _WordBitCarouselScreenState extends State<WordBitCarouselScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  bool _isFlipped = false;
  int _currentIndex = 0;

  // عينة تدعم تعدد الأزواج اللغوية العالمية ديناميكياً
  final List<UniversalCardItem> _cards = const [
    UniversalCardItem(
      targetWord: 'die Herausforderung',
      targetLocale: 'de-DE',
      sourceTranslation: 'التحدي',
      sourceLocale: 'ar-SA',
      targetExample: 'Das ist eine echte Herausforderung.',
      sourceExample: 'هذا تحدٍ حقيقي.',
      partOfSpeech: 'Nomen (f)',
    ),
    UniversalCardItem(
      targetWord: 'l’apprentissage',
      targetLocale: 'fr-FR',
      sourceTranslation: 'التعلم والتدرّب',
      sourceLocale: 'ar-SA',
      targetExample: 'L’apprentissage demande de la patience.',
      sourceExample: 'التعلم يتطلب صبراً.',
      partOfSpeech: 'Nom (m)',
    ),
    UniversalCardItem(
      targetWord: 'مستقبل',
      targetLocale: 'ar-SA',
      sourceTranslation: 'Future',
      sourceLocale: 'en-US',
      targetExample: 'المستقبل يبدأ اليوم.',
      sourceExample: 'The future begins today.',
      partOfSpeech: 'اسم',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'بطاقات التعلم العالمي (100 لغة)',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / _cards.length,
                  minHeight: 6,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 380,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _cards.length,
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
                        final rotateAnim = Tween(begin: math.pi, end: 0.0).animate(animation);
                        return AnimatedBuilder(
                          animation: rotateAnim,
                          child: child,
                          builder: (context, child) {
                            final isUnder = (ValueKey(_isFlipped) != child?.key);
                            var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.002;
                            tilt = isUnder ? -tilt : tilt;
                            return Transform(
                              transform: Matrix4.rotationY(rotateAnim.value)..setEntry(3, 0, tilt),
                              alignment: Alignment.center,
                              child: child,
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
                children: [
                  Expanded(child: _buildActionButton('صعب', const Color(0xFFEF4444))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildActionButton('جيد', const Color(0xFF3B82F6))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildActionButton('سهل', const Color(0xFF10B981))),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildFront(UniversalCardItem card) {
    final targetDir = LanguageBiDiHelper.getDirection(card.targetLocale);
    final targetHeight = LanguageBiDiHelper.getLineHeight(card.targetLocale);

    return Card(
      key: const ValueKey(false),
      elevation: 8,
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  '${card.partOfSpeech} • [${card.targetLocale}]',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
              const SizedBox(height: 24),
              Directionality(
                textDirection: targetDir,
                child: Text(
                  card.targetWord,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: targetHeight,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('المس لقلب البطاقة ومعرفة المعنى', style: TextStyle(color: Colors.white38, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBack(UniversalCardItem card) {
    final sourceDir = LanguageBiDiHelper.getDirection(card.sourceLocale);
    final sourceHeight = LanguageBiDiHelper.getLineHeight(card.sourceLocale);
    final targetDir = LanguageBiDiHelper.getDirection(card.targetLocale);

    return Card(
      key: const ValueKey(true),
      elevation: 8,
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Directionality(
                textDirection: sourceDir,
                child: Text(
                  card.sourceTranslation,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF38BDF8),
                    height: sourceHeight,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Divider(color: Colors.white.withAlpha(25)),
              const SizedBox(height: 12),
              Directionality(
                textDirection: targetDir,
                child: Text(
                  card.targetExample,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.white70, fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 8),
              Directionality(
                textDirection: sourceDir,
                child: Text(
                  card.sourceExample,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.white54, height: sourceHeight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withAlpha(50),
        foregroundColor: color,
        side: BorderSide(color: color, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      onPressed: () {
        if (_currentIndex < _cards.length - 1) {
          _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        }
      },
      child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}
