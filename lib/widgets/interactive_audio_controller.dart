import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class InteractiveAudioController extends StatefulWidget {
  final String primaryText;
  final String primaryLocale; // e.g. 'de-DE', 'en-US', 'fr-FR'
  final String? translatedText;
  final String translatedLocale; // e.g. 'ar-SA'

  const InteractiveAudioController({
    super.key,
    required this.primaryText,
    this.primaryLocale = 'de-DE',
    this.translatedText,
    this.translatedLocale = 'ar-SA',
  });

  @override
  State<InteractiveAudioController> createState() => _InteractiveAudioControllerState();
}

class _InteractiveAudioControllerState extends State<InteractiveAudioController> {
  final FlutterTts _tts = FlutterTts();
  
  int _repeatTarget = 1;
  int _currentIteration = 0;
  double _speechRate = 0.5; // السرعة الافتراضية المناسبة للتعلم
  bool _isPlaying = false;
  bool _isCancelled = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> _speakLoop({required String text, required String locale}) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _isPlaying = true;
      _isCancelled = false;
      _currentIteration = 0;
    });

    await _tts.setLanguage(locale);
    await _tts.setSpeechRate(_speechRate);

    for (int i = 1; i <= _repeatTarget; i++) {
      if (_isCancelled || !mounted) break;

      setState(() => _currentIteration = i);
      await _tts.speak(text);

      // انتظار انتهاء نطق الكلمة ثم فاصل مريح قبل التكرار التالي
      await Future.delayed(Duration(milliseconds: (1200 / _speechRate).round()));

      if (_isCancelled || !mounted) break;
    }

    if (mounted) {
      setState(() {
        _isPlaying = false;
        _currentIteration = 0;
      });
    }
  }

  void _stop() {
    _isCancelled = true;
    _tts.stop();
    setState(() {
      _isPlaying = false;
      _currentIteration = 0;
    });
  }

  @override
  void dispose() {
    _isCancelled = true;
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // عداد التكرارات من 1 إلى 9
          Row(
            children: [
              const Icon(Icons.repeat_rounded, size: 20, color: Colors.blueAccent),
              const SizedBox(width: 8),
              const Text(
                'مرات التكرار:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const Spacer(),
              Wrap(
                spacing: 4,
                children: List.generate(9, (index) {
                  final val = index + 1;
                  final isSelected = _repeatTarget == val;
                  return InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: _isPlaying ? null : () => setState(() => _repeatTarget = val),
                    child: Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blueAccent : Colors.grey.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$val',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 14),
          
          // مؤشر سرعة النطق
          Row(
            children: [
              const Icon(Icons.speed_rounded, size: 20, color: Colors.teal),
              const SizedBox(width: 8),
              Text(
                'السرعة: ${_speechRate.toStringAsFixed(2)}x',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Expanded(
                child: Slider(
                  value: _speechRate,
                  min: 0.25,
                  max: 1.0,
                  divisions: 6,
                  label: '${_speechRate.toStringAsFixed(2)}x',
                  onChanged: _isPlaying
                      ? null
                      : (val) => setState(() => _speechRate = val),
                ),
              ),
            ],
          ),
          const Divider(height: 16),

          // أزرار التشغيل والتحكم التفاعلي
          Row(
            children: [
              // زر نطق اللغة الأساسية
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: Icon(_isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded),
                  label: Text(
                    _isPlaying
                        ? 'إيقاف ($_currentIteration/$_repeatTarget)'
                        : 'نطق الأصل',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    if (_isPlaying) {
                      _stop();
                    } else {
                      _speakLoop(
                        text: widget.primaryText,
                        locale: widget.primaryLocale,
                      );
                    }
                  },
                ),
              ),
              
              // زر نطق الترجمة (إن وجدت)
              if (widget.translatedText != null && widget.translatedText!.isNotEmpty) ...[
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: 'نطق الترجمة',
                  icon: const Icon(Icons.translate_rounded),
                  onPressed: _isPlaying
                      ? null
                      : () {
                          _speakLoop(
                            text: widget.translatedText!,
                            locale: widget.translatedLocale,
                          );
                        },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
