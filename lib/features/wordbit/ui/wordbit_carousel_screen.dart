import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/language_bidi_helper.dart';
import '../../../core/lexical_repository.dart';
import '../models/wordbit_card.dart';
import '../../../core/audio/offline_audio_dispatcher.dart';
import '../../../core/srs/bridge/srs_compat_bridge.dart';

class WordBitCarouselScreen extends StatefulWidget {
  final String sourceLocale;
  final String targetLocale;

  const WordBitCarouselScreen(
      {super.key, this.sourceLocale = 'ar-SA', this.targetLocale = 'de-DE'});

  @override
  State<WordBitCarouselScreen> createState() => _WordBitCarouselScreenState();
}

class _WordBitCarouselScreenState extends State<WordBitCarouselScreen> {
  final PageController pageController = PageController(viewportFraction: 0.9);
  bool isFlipped = false;
  int currentIndex = 0;
  bool _isProcessing = false;

  List<WordBitCard> cards = [];

  @override
  void initState() {
    super.initState();
    refreshCards();
  }

  @override
  void didUpdateWidget(WordBitCarouselScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sourceLocale != widget.sourceLocale ||
        oldWidget.targetLocale != widget.targetLocale) {
      OfflineAudioDispatcher.stopCurrentAudio();
      refreshCards();
    }
  }

  void refreshCards() {
    final entries = LexicalRepository.getEntriesForPair(
      sourceLocale: widget.sourceLocale,
      targetLocale: widget.targetLocale,
    );

    setState(() {
      cards = entries
          .map((e) => WordBitCard(
                id: e.id,
                term: e.targetTerm,
                ipa: '', // fallback if not in LexicalEntry
                partOfSpeech: e.partOfSpeech,
                translation: e.sourceMeaning,
                exampleSentence: e.targetExample,
                sourceExampleTranslation: e.sourceExampleTranslation,
                domainName: e.domainId,
                bcp47Locale: e.targetLocale,
                sourceLocale: e.sourceLocale,
              ))
          .toList();
      currentIndex = 0;
      isFlipped = false;
    });
  }

  @override
  void dispose() {
    OfflineAudioDispatcher.stopCurrentAudio();
    pageController.dispose();
    super.dispose();
  }

  void flipCard() {
    setState(() {
      isFlipped = !isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: Text(
            'لا توجد بطاقات متاحة حالياً',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'بطاقات التعلم العالمي (100 لغة)',
          style: TextStyle(
              fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 18),
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
                  value: (currentIndex + 1) / cards.length,
                  minHeight: 6,
                  backgroundColor: Colors.white10,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 380,
              child: PageView.builder(
                controller: pageController,
                itemCount: cards.length,
                onPageChanged: (index) {
                  OfflineAudioDispatcher.stopCurrentAudio();
                  setState(() {
                    currentIndex = index;
                    isFlipped = false;
                  });
                },
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return GestureDetector(
                    onTap: flipCard,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (child, animation) {
                        final rotateAnim =
                            Tween(begin: math.pi, end: 0.0).animate(animation);
                        return AnimatedBuilder(
                          animation: rotateAnim,
                          child: child,
                          builder: (context, child) {
                            final isUnder =
                                (ValueKey(isFlipped) != child?.key);
                            var tilt =
                                ((animation.value - 0.5).abs() - 0.5) * 0.002;
                            tilt = isUnder ? -tilt : tilt;
                            return Transform(
                              transform: Matrix4.rotationY(rotateAnim.value)
                                ..setEntry(3, 0, tilt),
                              alignment: Alignment.center,
                              child: child,
                            );
                          },
                        );
                      },
                      child: isFlipped ? buildBack(card) : buildFront(card),
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
                  Expanded(
                      child: buildActionButton(
                          'صعب', const Color(0xFFEF4444), 2)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: buildActionButton(
                          'جيد', const Color(0xFF3B82F6), 3)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: buildActionButton(
                          'سهل', const Color(0xFF10B981), 4)),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget buildFront(WordBitCard card) {
    final targetDir = LanguageBiDiHelper.getDirection(card.bcp47Locale);
    final targetHeight = LanguageBiDiHelper.getLineHeight(card.bcp47Locale);

    return Card(
      key: const ValueKey(false),
      elevation: 8,
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    '${card.partOfSpeech} • [${card.bcp47Locale}]',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 24),
                // REQUIRED ADAPTER: A vector decoding adapter (e.g., flutter_svg) is required to render concept vectors. This is out of scope.
                Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(16)),
                    child: SingleChildScrollView(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          const Icon(Icons.image_not_supported,
                              color: Colors.white38,
                              size: 40,
                              semanticLabel: 'Concept illustration absent'),
                          const SizedBox(height: 8),
                          Text(card.id,
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 10)),
                        ]))),
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
                if (card.ipa.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '/${card.ipa}/',
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                const SizedBox(height: 16),
                IconButton(
                  icon: const Icon(Icons.volume_up,
                      color: Color(0xFF38BDF8), size: 32),
                  onPressed: () {
                    OfflineAudioDispatcher.speakText(
                        text: card.term, bcp47Locale: card.bcp47Locale);
                  },
                ),
                const SizedBox(height: 8),
                const Text('المس لقلب البطاقة ومعرفة المعنى',
                    style: TextStyle(color: Colors.white38, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBack(WordBitCard card) {
    final sourceDir = LanguageBiDiHelper.getDirection(card.sourceLocale);
    final sourceHeight = LanguageBiDiHelper.getLineHeight(card.sourceLocale);
    final targetDir = LanguageBiDiHelper.getDirection(card.bcp47Locale);

    return Card(
      key: const ValueKey(true),
      elevation: 8,
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Directionality(
                  textDirection: sourceDir,
                  child: Text(
                    card.translation,
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
                    card.exampleSentence,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic),
                  ),
                ),
                const SizedBox(height: 8),
                Directionality(
                  textDirection: sourceDir,
                  child: Text(
                    card.sourceExampleTranslation,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.white54,
                        height: sourceHeight),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildActionButton(String label, Color color, int rating) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withAlpha(50),
        foregroundColor: color,
        side: BorderSide(color: color, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      onPressed: () async {
        if (_isProcessing || cards.isEmpty) return;
        setState(() {
          _isProcessing = true;
        });

        final card = cards[currentIndex];
        await SrsCompatBridge.instance.recordReviewCompat(
          contentKey: card.id,
          rating: rating,
          sourceIso: card.sourceLocale,
          targetIso: card.bcp47Locale,
        );

        if (currentIndex < cards.length - 1) {
          await pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut);
          if (mounted) {
            setState(() {
              _isProcessing = false;
            });
          }
        } else {
          if (mounted) Navigator.of(context).pop();
        }
      },
      child: Text(label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}
