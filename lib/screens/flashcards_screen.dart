import 'package:flutter/material.dart';
import 'dart:math';
import '../widgets/language_selector_button.dart';
import '../core/srs/review_command_port.dart';
import '../core/audio/offline_audio_manager.dart';
import '../services/local_database_service.dart';
import '../services/database_service.dart';
import '../widgets/phonetic_ipa_view.dart';
import '../widgets/bidi_lexicon_view.dart';
import '../widgets/noun_classifier_view.dart';
import '../widgets/idioms_view.dart';
import '../widgets/example_sentences_view.dart';
import 'word_deep_dive_sheet.dart' as detail;

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

class _FlashcardsScreenState extends State<FlashcardsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFlipped = false;
  bool _isSubmitting = false;
  Map<String, dynamic> _card = <String, dynamic>{
    'lemma': 'das Buch',
    'surface': 'das Buch',
    'translation_ar': 'الكتاب',
    'sentence': 'Ich lese ein Buch.',
  };

  String _value(String key, [String fallback = '']) =>
      _card[key]?.toString().trim().isNotEmpty == true
          ? _card[key].toString().trim()
          : fallback;

  Map<String, dynamic> get _fields {
    final raw = _card['fields'];
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }

  Future<void> _loadWord() async {
    try {
      final words = await DatabaseService.instance.searchDictionary('', 'de');
      if (mounted && words.isNotEmpty) {
        setState(() => _card = words.first);
      }
    } catch (_) {
      // Retain the original offline fallback card if the pack is unavailable.
    }
  }


  @override
  void initState() {
    super.initState();
    _loadWord();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(_flipController);
  }

  @override
  void dispose() {
    _flipController.dispose();
    OfflineAudioManager.instance.stop(); 
    super.dispose();
  }

  void _toggleFlip() {
    if (_isSubmitting) return;
    setState(() {
      _isFlipped = !_isFlipped;
    });
    if (_isFlipped) {
      _flipController.forward();
      OfflineAudioManager.instance.speak(_value('lemma', _value('surface', 'das Buch'))); 
    } else {
      _flipController.reverse();
    }
  }

  Future<void> _handleRating(ReviewRating rating) async {
    if (_isSubmitting) return; 
    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(milliseconds: 300)); 
    
    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _isFlipped = false;
      });
      _flipController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مراجعة اليوم', style: TextStyle(fontFamily: 'Cairo')),
        actions: const [LanguageSelectorButton()],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: LinearProgressIndicator(value: 0.3, backgroundColor: Colors.white24),
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
                        child: isFront ? _buildFrontAppBaseGlassCard() : _buildBackAppBaseGlassCard(),
                      );
                    },
                  ),
                ),
              ),
            ),
            if (_isFlipped)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: _isSubmitting 
                  ? const CircularProgressIndicator()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildRatingButton('مجدداً', Colors.redAccent, ReviewRating.again),
                        _buildRatingButton('صعب', Colors.orangeAccent, ReviewRating.hard),
                        _buildRatingButton('جيد', Colors.blueAccent, ReviewRating.good),
                        _buildRatingButton('سهل', Colors.green, ReviewRating.easy),
                      ],
                    ),
              )
            else
              const Padding(
                padding: EdgeInsets.all(40.0),
                child: Text('اضغط للكشف والاستماع', style: TextStyle(color: Colors.white54)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrontAppBaseGlassCard() {
    final word = _value('lemma', _value('surface', 'das Buch'));
    final ipa = _fields['ipa']?.toString() ?? _value('ipa');
    return Container(
      width: 320,
      height: 400,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            word,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white,
            ),
          ),
          if (hasPhoneticData(ipa)) ...<Widget>[
            const SizedBox(height: 10),
            PhoneticIpaView(ipa: ipa),
          ],
        ],
      ),
    );
  }

  Widget _buildBackAppBaseGlassCard() {
    final fields = _fields;
    final word = _value('lemma', _value('surface', 'das Buch'));
    final languageCode = _value('language_code', 'de');
    final ipa = fields['ipa']?.toString() ?? _value('ipa');
    final examples = detail.WordDeepDiveSheet.examplesJsonFor(_card);
    final headwordId = _value('id');
    final classifier = fields['classifier']?.toString() ??
        fields['measure_word']?.toString() ?? '';
    final partOfSpeech = _value('part_of_speech');
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateX(pi),
      child: Container(
        width: 320,
        height: 400,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF334155),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (partOfSpeech.isNotEmpty)
                NounClassifierView(
                  noun: word,
                  languageCode: languageCode,
                  partOfSpeech: partOfSpeech,
                  classifier: classifier,
                  reading: fields['classifier_reading']?.toString() ?? '',
                  explanation:
                      fields['classifier_explanation']?.toString() ?? '',
                ),
              BidiLexiconView(
                sourceWord: word,
                sourceLanguageCode: languageCode,
                targetExplanation: _value('translation_ar', 'الكتاب'),
                phonetic: hasPhoneticData(ipa)
                    ? PhoneticIpaView(ipa: ipa)
                    : null,
              ),
              if (examples != null)
                ExampleSentencesView(
                  examplesJson: examples,
                  keyword: word,
                  sourceLanguageCode: languageCode,
                ),
              if (headwordId.isNotEmpty)
                IdiomsView(
                  headwordId: headwordId,
                  languageCode: languageCode,
                ),
              TextButton(
                onPressed: () => detail.WordDeepDiveSheet.show(
                  context,
                  wordData: _card,
                ),
                child: const Text('تفاصيل المفردة'),
              ),
            ],
          ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () => _handleRating(rating),
      child: Text(label, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
    );
  }
}
