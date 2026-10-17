import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/core/lexical_repository.dart';
import 'package:deutsch_bilarabi/services/language_pack_manager.dart';
import 'package:deutsch_bilarabi/core/language_bidi_helper.dart';
import 'package:deutsch_bilarabi/services/trie_search_engine.dart';
import 'package:deutsch_bilarabi/core/audio/offline_audio_dispatcher.dart';
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

class _DictationTrainerScreenState extends State<DictationTrainerScreen> with WidgetsBindingObserver {
  final TextEditingController _answerController = TextEditingController();
  bool _checked = false;
  bool _isCorrect = false;
  bool _isInitializing = true;
  bool _isTtsAvailable = false;
  String _ttsLocale = '';

  LexicalEntry? _currentEntry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initLesson();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    OfflineAudioDispatcher.stopCurrentAudio();
    _answerController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initLesson();
    }
  }

  String _getTtsLocale(String languageCode) {
    for (final bcp47 in LanguagePackManager.supportedBcp47Locales) {
      if (bcp47.startsWith(languageCode)) return bcp47;
    }
    return '';
  }

  Future<void> _initLesson() async {
    final entries = LexicalRepository.getEntriesForPair(
      sourceLocale: widget.sourceLocale,
      targetLocale: widget.targetLocale,
    );

    if (entries.isNotEmpty) {
      _currentEntry = entries.first;
      _ttsLocale = _getTtsLocale(widget.targetLocale);
      if (_ttsLocale.isNotEmpty) {
        _isTtsAvailable = await LanguagePackManager.verifyAndMountOfflinePack(_ttsLocale);
      } else {
        _isTtsAvailable = false;
      }
    }

    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  void _playAudio() async {
    if (_currentEntry == null || !_isTtsAvailable || _ttsLocale.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الصوت غير متاح حالياً للغة المحددة.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    await OfflineAudioDispatcher.speakText(
      text: _currentEntry!.targetTerm,
      bcp47Locale: _ttsLocale,
    );
  }

  void _checkAnswer() async {
    if (_checked || _currentEntry == null) return;

    final answer = _answerController.text;
    final normalizedAnswer = TrieSearchEngine.normalizeUniversal(answer);
    final normalizedTarget = TrieSearchEngine.normalizeUniversal(_currentEntry!.targetTerm);

    final correct = normalizedAnswer == normalizedTarget;

    setState(() {
      _checked = true;
      _isCorrect = correct;
    });

    final rating = correct ? 4 : 1;

    // Do not record progress if screen is disposed during checking
    if (mounted) {
      await SrsCompatBridge.instance.recordReviewCompat(
        contentKey: _currentEntry!.id,
        rating: rating,
        sourceIso: widget.sourceLocale,
        targetIso: widget.targetLocale,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentEntry == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('مدرب الاستماع والتهجئة')),
        body: const Center(
          child: Text(
            'لا توجد مفردات متاحة للتدريب حالياً.',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    final targetDirection = LanguageBiDiHelper.getDirection(widget.targetLocale);

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
                        _isTtsAvailable ? Icons.headphones_rounded : Icons.headset_off_rounded,
                        color: _isTtsAvailable ? const Color(0xFF38BDF8) : Colors.white38,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isTtsAvailable
                            ? 'استمع للكلمة واكتبها إملائياً بصورة صحيحة'
                            : 'الصوت غير متوفر محلياً، اكتب الكلمة بناءً على المعنى',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'المعنى المساعد: ${_currentEntry!.sourceMeaning}',
                        style: const TextStyle(color: Color(0xFF34D399), fontSize: 14, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      IconButton(
                        iconSize: 56,
                        color: _isTtsAvailable ? const Color(0xFF38BDF8) : Colors.white38,
                        icon: const Icon(Icons.play_circle_fill_rounded),
                        onPressed: _playAudio,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Directionality(
                  textDirection: targetDirection,
                  child: TextField(
                    controller: _answerController,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    enabled: !_checked,
                    decoration: InputDecoration(
                      hintText: 'اكتب التهجئة الصحيحة هنا...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
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
                      _isCorrect
                          ? 'إجابة صحيحة تماماً! أحسنت 🚀'
                          : 'خطأ تهجئي بسيط، الكلمة الصحيحة هي: ${_currentEntry!.targetTerm}',
                      style: TextStyle(color: _isCorrect ? const Color(0xFF34D399) : const Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _checked ? Colors.grey : const Color(0xFF38BDF8),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _checked ? null : _checkAnswer,
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
