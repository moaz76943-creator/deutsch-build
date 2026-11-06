import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/core/lexical_repository.dart';
import 'package:deutsch_bilarabi/core/audio/offline_audio_dispatcher.dart';
import 'package:deutsch_bilarabi/core/language_bidi_helper.dart';
import 'package:deutsch_bilarabi/core/srs/bridge/srs_compat_bridge.dart';
import 'package:flutter/services.dart';

class DictationTrainerScreen extends StatefulWidget {
  final String sourceLocale;
  final String targetLocale;

  const DictationTrainerScreen({super.key, this.sourceLocale = 'ar', this.targetLocale = 'de'});

  @override
  State<DictationTrainerScreen> createState() => _DictationTrainerScreenState();
}

class _DictationTrainerScreenState extends State<DictationTrainerScreen> {
  final TextEditingController _answerController = TextEditingController();
  bool _checked = false;
  bool _isCorrect = false;
  bool _isVoiceAvailable = false;
  bool _isVoiceLoading = true;
  LexicalEntry? _currentEntry;
  int _attempts = 0;
  bool _submitted = false;

  final MethodChannel _voiceChannel =
      const MethodChannel('com.deutschbilarabi.app/offline_voice_capability');

  @override
  void initState() {
    super.initState();
    _loadEntry();
  }

  Future<void> _loadEntry() async {
    // Load an entry for the specified pair. Do not use test fallbacks here.
    List<LexicalEntry> entries = LexicalRepository.getEntriesForPair(sourceLocale: widget.sourceLocale, targetLocale: widget.targetLocale);

    if (entries.isEmpty) {
      // Fallback if empty
      if (mounted) {
        setState(() {
          _isVoiceLoading = false;
          _isVoiceAvailable = false;
        });
      }
      return;
    }

    final entry = entries.first;
    if (mounted) {
      setState(() {
        _currentEntry = entry;
      });
    }

    await _checkVoiceAvailability(entry.targetLocale);
  }

  Future<void> _checkVoiceAvailability(String locale) async {
    try {
      final List<dynamic>? voices =
          await _voiceChannel.invokeMethod('getOfflineVoices');
      bool available = false;
      if (voices != null) {
        for (final v in voices) {
          if (v.toString().startsWith(locale.split('-').first)) {
            available = true;
            break;
          }
        }
      }

      if (mounted) {
        setState(() {
          _isVoiceAvailable = available;
          _isVoiceLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVoiceAvailable = false;
          _isVoiceLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    OfflineAudioDispatcher.stopCurrentAudio();
    _answerController.dispose();
    super.dispose();
  }

  // Basic unicode normalization for answer comparison
  String _normalizeString(String input) {
    // Basic normalization: trim and lowercase and remove extra spaces
    // Preserve base scripts but remove standard Arabic diacritics (tashkeel)
    // using the existing regex pattern for robust spelling verification.
    input = input.replaceAll(RegExp(r'[ً-ٰٟ]'), '');
    return input.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  void _checkAnswer() {
    if (_currentEntry == null || _submitted) return;

    setState(() {
      _attempts++;
      _checked = true;
      final normalizedInput = _normalizeString(_answerController.text);
      final normalizedTarget = _normalizeString(_currentEntry!.targetTerm);
      _isCorrect = normalizedInput == normalizedTarget;

      if (_isCorrect || _attempts >= 3) {
        _submitted = true;
        // submit progress
        int rating = _isCorrect ? 3 : 0; // 3 for easy/correct, 0 for wrong
        SrsCompatBridge.instance.recordReviewCompat(
          contentKey: _currentEntry!.id,
          rating: rating,
          sourceIso: _currentEntry!.sourceLocale,
          targetIso: _currentEntry!.targetLocale,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentEntry == null && !_isVoiceLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('مدرب الاستماع والتهجئة')),
        body: const Center(
            child: Text('لا توجد مفردات متاحة للتدريب حالياً.',
                style: TextStyle(color: Colors.white))),
      );
    }

    if (_isVoiceLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('مدرب الاستماع والتهجئة')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final targetDir =
        LanguageBiDiHelper.getDirection(_currentEntry!.targetLocale);

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
                      const Icon(Icons.headphones_rounded,
                          color: Color(0xFF38BDF8), size: 48),
                      const SizedBox(height: 12),
                      Text(
                        _isVoiceAvailable
                            ? 'استمع للكلمة واكتبها إملائياً بصورة صحيحة'
                            : 'الصوت غير متاح حالياً. اقرأ المعنى واكتب الكلمة.',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text('المعنى المساعد: ${_currentEntry!.sourceMeaning}',
                          style: const TextStyle(
                              color: Color(0xFF34D399),
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      IconButton(
                        iconSize: 56,
                        color: _isVoiceAvailable
                            ? const Color(0xFF38BDF8)
                            : Colors.grey,
                        icon: const Icon(Icons.play_circle_fill_rounded),
                        onPressed: _isVoiceAvailable
                            ? () {
                                OfflineAudioDispatcher.speakText(
                                  text: _currentEntry!.targetTerm,
                                  bcp47Locale: _currentEntry!.targetLocale,
                                );
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Directionality(
                  textDirection: targetDir,
                  child: TextField(
                    controller: _answerController,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    enabled: !_submitted,
                    decoration: InputDecoration(
                      hintText: 'اكتب التهجئة الصحيحة هنا...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_checked)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (_isCorrect
                              ? const Color(0xFF34D399)
                              : const Color(0xFFEF4444))
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _isCorrect
                          ? 'إجابة صحيحة تماماً! أحسنت 🚀'
                          : (_submitted
                              ? 'خطأ تهجئي بسيط، الكلمة الصحيحة هي: ${_currentEntry!.targetTerm}'
                              : 'حاول مرة أخرى'),
                      style: TextStyle(
                          color: _isCorrect
                              ? const Color(0xFF34D399)
                              : const Color(0xFFEF4444),
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _submitted ? Colors.grey : const Color(0xFF38BDF8),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _submitted ? null : _checkAnswer,
                  child: const Text('تحقق من التهجئة',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
