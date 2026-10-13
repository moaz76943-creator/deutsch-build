import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/core/lexical_repository.dart';
import 'package:deutsch_bilarabi/core/audio/offline_audio_dispatcher.dart';
import 'package:deutsch_bilarabi/core/srs/bridge/srs_compat_bridge.dart';
import 'package:deutsch_bilarabi/core/language_bidi_helper.dart';
import 'package:deutsch_bilarabi/services/trie_search_engine.dart';

class DictationTrainerScreen extends StatefulWidget {
  const DictationTrainerScreen({super.key});

  @override
  State<DictationTrainerScreen> createState() => _DictationTrainerScreenState();
}

class _DictationTrainerScreenState extends State<DictationTrainerScreen> {
  final TextEditingController _answerController = TextEditingController();
  bool _checked = false;
  bool _isCorrect = false;
  int _attempts = 0;
  bool _voiceAvailable = true;

  late String _targetWord;
  late String _targetMeaning;
  late String _targetLocale;
  late String _sourceLocale;
  late String _entryId;

  @override
  void initState() {
    super.initState();
    _loadEntry();
  }

  void _loadEntry() {
    // We fetch an entry if available in the repository.
    final entries = LexicalRepository.getEntriesByDomain('dictation_practice');
    if (entries.isNotEmpty) {
      final entry = entries.first;
      _targetWord = entry.targetTerm;
      _targetMeaning = entry.sourceMeaning;
      _targetLocale = entry.targetLocale;
      _sourceLocale = entry.sourceLocale;
      _entryId = entry.id;
    } else {
      // Fallback
      _targetWord = "Verantwortung";
      _targetMeaning = "المسؤولية";
      _targetLocale = "de-DE";
      _sourceLocale = "ar-SA";
      _entryId = "fallback_dict_1";
    }
  }

  @override
  void dispose() {
    OfflineAudioDispatcher.stopCurrentAudio();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _playAudio() async {
    final success = await OfflineAudioDispatcher.speakText(
      text: _targetWord,
      bcp47Locale: _targetLocale,
    );
    if (mounted) {
      setState(() {
        _voiceAvailable = success;
      });
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('الصوت غير متوفر حالياً. يمكنك الاعتماد على المعنى للحل.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _checkAnswer() {
    if (_attempts >= 3 && !_isCorrect) return; // Prevent extra attempts if maxed out

    setState(() {
      _attempts++;
      _checked = true;
      _isCorrect = _normalizeText(_answerController.text) == _normalizeText(_targetWord);
    });

    if (_isCorrect) {
      SrsCompatBridge.instance.recordReviewCompat(
        contentKey: _entryId,
        rating: 4, // 4 could mean 'good' or correct based on some mapping
        sourceIso: _sourceLocale,
        targetIso: _targetLocale,
      );
    }
  }

  String _normalizeText(String text) {
    return TrieSearchEngine.normalizeUniversal(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مدرب الاستماع والتهجئة (Dictation)'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppBaseGlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: <Widget>[
                      Icon(
                        _voiceAvailable ? Icons.headphones_rounded : Icons.speaker_notes_off,
                        color: const Color(0xFF38BDF8),
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _voiceAvailable ? 'استمع للكلمة واكتبها إملائياً بصورة صحيحة' : 'الصوت غير متوفر. ترجم المعنى للغة الهدف.',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'المعنى المساعد: $_targetMeaning',
                        style: const TextStyle(color: Color(0xFF34D399), fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      IconButton(
                        iconSize: 56,
                        color: const Color(0xFF38BDF8),
                        icon: const Icon(Icons.play_circle_fill_rounded),
                        onPressed: _playAudio,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _answerController,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  textDirection: LanguageBiDiHelper.getDirection(_targetLocale),
                  decoration: InputDecoration(
                    hintText: 'اكتب التهجئة الصحيحة هنا...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  enabled: !_isCorrect && _attempts < 3,
                ),
                const SizedBox(height: 16),
                if (_checked)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (_isCorrect ? const Color(0xFF34D399) : const Color(0xFFEF4444)).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _isCorrect
                          ? 'إجابة صحيحة تماماً! أحسنت 🚀'
                          : (_attempts >= 3 ? 'لقد استنفدت المحاولات. الكلمة هي: $_targetWord' : 'خطأ تهجئي، حاول مرة أخرى. الكلمة المطلوبة: $_targetWord'),
                      style: TextStyle(
                        color: _isCorrect ? const Color(0xFF34D399) : const Color(0xFFEF4444),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: (_isCorrect || _attempts >= 3) ? null : _checkAnswer,
                  child: const Text('تحقق من التهجئة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
