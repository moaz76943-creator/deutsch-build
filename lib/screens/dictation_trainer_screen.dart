import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/core/audio/offline_audio_dispatcher.dart';
import 'package:deutsch_bilarabi/core/lexical_repository.dart';
import 'package:deutsch_bilarabi/services/trie_search_engine.dart';
import 'package:deutsch_bilarabi/core/srs/bridge/srs_compat_bridge.dart';

class DictationTrainerScreen extends StatefulWidget {
  final String sourceLocale;
  final String targetLocale;

  const DictationTrainerScreen({
    super.key,
    this.sourceLocale = 'ar',
    this.targetLocale = 'de',
  });

  @override
  State<DictationTrainerScreen> createState() => _DictationTrainerScreenState();
}

class _DictationTrainerScreenState extends State<DictationTrainerScreen> {
  final TextEditingController _answerController = TextEditingController();
  bool _checked = false;
  bool _isCorrect = false;
  bool _isUnavailable = false;
  bool _isLoading = true;
  bool _isProcessing = false;

  List<LexicalEntry> _entries = [];
  int _currentIndex = 0;

  LexicalEntry? get _currentEntry => _entries.isNotEmpty && _currentIndex < _entries.length ? _entries[_currentIndex] : null;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  void _loadEntries() {
    final entries = LexicalRepository.getEntriesForPair(
      sourceLocale: widget.sourceLocale,
      targetLocale: widget.targetLocale,
    );

    setState(() {
      _entries = entries;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    OfflineAudioDispatcher.stopCurrentAudio();
    _answerController.dispose();
    super.dispose();
  }

  void _playAudio() async {
    if (_currentEntry == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جارٍ تشغيل الصوت...'), duration: Duration(seconds: 1)),
    );

    final success = await OfflineAudioDispatcher.speakText(
      text: _currentEntry!.targetTerm,
      bcp47Locale: widget.targetLocale,
    );

    if (!success && mounted) {
      setState(() {
        _isUnavailable = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الصوت غير متاح حالياً. يرجى التدرب على الكتابة.')),
      );
    }
  }

  void _checkAnswer() async {
    if (_currentEntry == null || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    final userAnswer = _answerController.text;
    final normalizedUserAnswer = TrieSearchEngine.normalizeUniversal(userAnswer);
    final normalizedTarget = TrieSearchEngine.normalizeUniversal(_currentEntry!.targetTerm);

    final isCorrect = normalizedUserAnswer == normalizedTarget;

    await SrsCompatBridge.instance.recordReviewCompat(
      contentKey: _currentEntry!.id,
      rating: isCorrect ? 3 : 1, // 3: easy, 1: hard
      sourceIso: widget.sourceLocale,
      targetIso: widget.targetLocale,
    );

    if (mounted) {
      setState(() {
        _checked = true;
        _isCorrect = isCorrect;
        _isProcessing = false;
      });
    }
  }

  void _nextWord() {
    if (_isProcessing) return;
    setState(() {
      _currentIndex++;
      _checked = false;
      _isCorrect = false;
      _answerController.clear();
      // Keep _isUnavailable state intentionally for the remainder of the session to avoid multiple failed TTS calls.
    });
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
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _entries.isEmpty
                ? const Center(child: Text('لا توجد كلمات للتدرب عليها', style: TextStyle(color: Colors.white)))
                : _currentIndex >= _entries.length
                  ? const Center(child: Text('لقد أتممت التدريب! 🎉', style: TextStyle(color: Colors.white, fontSize: 24)))
                  : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppBaseGlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: <Widget>[
                      Icon(
                        _isUnavailable ? Icons.volume_off_rounded : Icons.headphones_rounded,
                        color: _isUnavailable ? Colors.grey : const Color(0xFF38BDF8),
                        size: 48
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isUnavailable ? 'الصوت غير متوفر، اكتب الكلمة بناءً على المعنى' : 'استمع للكلمة واكتبها إملائياً بصورة صحيحة',
                        style: const TextStyle(color: Colors.white70, fontSize: 14)
                      ),
                      const SizedBox(height: 8),
                      Text('المعنى المساعد: ${_currentEntry!.sourceMeaning}', style: const TextStyle(color: Color(0xFF34D399), fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      IconButton(
                        iconSize: 56,
                        color: _isUnavailable ? Colors.grey : const Color(0xFF38BDF8),
                        icon: const Icon(Icons.play_circle_fill_rounded),
                        onPressed: _isUnavailable ? null : _playAudio,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _answerController,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'اكتب التهجئة الصحيحة هنا...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
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
                      _isCorrect ? 'إجابة صحيحة تماماً! أحسنت 🚀' : 'خطأ تهجئي بسيط، الكلمة الصحيحة هي: ${_currentEntry!.targetTerm}',
                      style: TextStyle(color: _isCorrect ? const Color(0xFF34D399) : const Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 14),
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
                  onPressed: _isProcessing ? null : (_checked ? _nextWord : _checkAnswer),
                  child: Text(_checked ? 'الكلمة التالية' : 'تحقق من التهجئة', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
