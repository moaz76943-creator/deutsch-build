import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/audio/offline_audio_manager.dart';
import '../core/srs/review_command_port.dart';
import '../providers/active_language_provider.dart';
import '../services/database_service.dart';
import '../services/fts_search_service.dart';
import '../widgets/bidi_lexicon_view.dart';
import '../widgets/example_sentences_view.dart';
import '../widgets/idioms_view.dart';
import '../widgets/language_selector_button.dart';
import '../widgets/noun_classifier_view.dart';
import '../widgets/phonetic_ipa_view.dart';
import 'word_deep_dive_sheet.dart' show WordDeepDiveSheet;

/// Open the installed content pack instead of displaying demonstration words.
Future<List<Map<String, dynamic>>> loadFlashcardsSafe(String targetLangCode) async {
  try {
    return await FtsSearchService().searchDictionary(
      '',
      targetLangCode,
      limit: 20,
    );
  } catch (_) {
    return DatabaseService.instance.searchDictionary('', targetLangCode);
  }
}

class FlashcardsScreen extends ConsumerStatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;

  List<Map<String, dynamic>> _cards = <Map<String, dynamic>>[];
  String _languageCode = 'de';
  int _cardIndex = 0;
  int _loadGeneration = 0;
  bool _isLoading = true;
  bool _isFlipped = false;
  bool _isSubmitting = false;
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
    _loadCards(ref.read(activeLanguageCodeProvider));
  }

  @override
  void dispose() {
    _loadGeneration++;
    _flipController.dispose();
    unawaited(OfflineAudioManager.instance.stop());
    super.dispose();
  }

  Future<void> _loadCards(String languageCode) async {
    final generation = ++_loadGeneration;
    if (!mounted) return;
    setState(() {
      _languageCode = languageCode;
      _isLoading = true;
      _isFlipped = false;
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
        unawaited(OfflineAudioManager.instance.speak(_headword));
      }
    } else {
      _flipController.reverse();
    }
  }

  Future<void> _handleRating(ReviewRating rating) async {
    if (_isSubmitting || _cards.isEmpty) return;
    setState(() => _isSubmitting = true);
    // The SRS scheduling port remains authoritative for review persistence;
    // UI ratings here only advance the visible card, as in the old screen.
    await _flipController.reverse();
    if (!mounted) return;
    setState(() {
      _cardIndex = (_cardIndex + 1) % _cards.length;
      _isFlipped = false;
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String>(activeLanguageCodeProvider, (previous, next) {
      if (next != previous && next != _languageCode) {
        unawaited(_loadCards(next));
      }
    });
    final progress = _cards.isEmpty ? 0.0 : (_cardIndex + 1) / _cards.length;

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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _cards.isEmpty
                      ? Center(
                          child: Text(_error ?? 'لا توجد بطاقات في الحزمة المثبّتة.'),
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
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          _ratingButton('مجدداً', Colors.redAccent, ReviewRating.again),
                          _ratingButton('صعب', Colors.orangeAccent, ReviewRating.hard),
                          _ratingButton('جيد', Colors.blueAccent, ReviewRating.good),
                          _ratingButton('سهل', Colors.green, ReviewRating.easy),
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
      width: 320,
      height: 400,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            _headword,
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
    );
  }

  Widget _buildBackCard() {
    final card = _currentCard!;
    final fields = <String, dynamic>{..._fields(card), ...card};
    final meaning = _string(fields, <String>['translation_ar', 'translation', 'meaning']);
    final pos = _string(fields, <String>['part_of_speech', 'pos']);
    final classifier = _string(fields, <String>['classifier', 'measure_word', 'noun_class']);
    final headwordId = _string(fields, <String>['id', 'lexeme_id']);
    final examplesJson = WordDeepDiveSheet.examplesJsonFor(card);

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateX(pi),
      child: Container(
        width: 320,
        height: 400,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF334155),
          borderRadius: BorderRadius.circular(24),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (pos.isNotEmpty || classifier.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    if (pos.isNotEmpty) Chip(label: Text(pos)),
                    NounClassifierView(
                      noun: _headword,
                      languageCode: _languageCode,
                      partOfSpeech: pos,
                      classifier: classifier,
                      reading: _string(fields, <String>['classifier_reading']),
                      explanation: _string(fields, <String>['classifier_explanation']),
                    ),
                  ],
                ),
              BidiLexiconView(
                sourceWord: _headword,
                sourceLanguageCode: _languageCode,
                targetExplanation: meaning,
              ),
              if (examplesJson != null)
                ExampleSentencesView(
                  examplesJson: examplesJson,
                  keyword: _headword,
                  sourceLanguageCode: _languageCode,
                ),
              if (headwordId.isNotEmpty)
                IdiomsView(headwordId: headwordId, languageCode: _languageCode),
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
