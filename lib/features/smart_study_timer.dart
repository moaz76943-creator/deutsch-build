import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TimerMode {
  pomodoro('بومودورو (25/5 د)', 25, 5, Icons.timer_outlined, Color(0xFFE53935)),
  rounds('نظام الجولات', 15, 3, Icons.repeat_rounded, Color(0xFF8E24AA)),
  custom('مؤقّت مخصص', 30, 0, Icons.tune_rounded, Color(0xFF1E88E5));

  final String label;
  final int defaultWorkMinutes;
  final int defaultBreakMinutes;
  final IconData icon;
  final Color themeColor;
  const TimerMode(this.label, this.defaultWorkMinutes, this.defaultBreakMinutes, this.icon, this.themeColor);
}

class SmartStudyTimerScreen extends StatefulWidget {
  const SmartStudyTimerScreen({super.key});

  @override
  State<SmartStudyTimerScreen> createState() => _SmartStudyTimerScreenState();
}

class _SmartStudyTimerScreenState extends State<SmartStudyTimerScreen> {
  final FlutterTts _tts = FlutterTts();
  
  TimerMode _currentMode = TimerMode.pomodoro;
  int _totalSeconds = 25 * 60;
  int _remainingSeconds = 25 * 60;
  Timer? _timer;
  bool _isRunning = false;
  bool _isBreak = false;
  int _currentRound = 1;
  int _totalRounds = 4;

  @override
  void initState() {
    super.initState();
    _initTts();
    _setMode(TimerMode.pomodoro);
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('ar-SA');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
  }

  void _setMode(TimerMode mode) {
    _pauseTimer();
    setState(() {
      _currentMode = mode;
      _isBreak = false;
      _currentRound = 1;
      _totalSeconds = mode.defaultWorkMinutes * 60;
      _remainingSeconds = _totalSeconds;
    });
  }

  void _startTimer() {
    if (_isRunning) return;
    HapticFeedback.mediumImpact();
    setState(() => _isRunning = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _handleSessionCompleted();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    HapticFeedback.lightImpact();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _pauseTimer();
    setState(() {
      _isBreak = false;
      _totalSeconds = _currentMode.defaultWorkMinutes * 60;
      _remainingSeconds = _totalSeconds;
    });
  }

  void _addExtraFiveMinutes() {
    HapticFeedback.selectionClick();
    setState(() {
      _totalSeconds += 5 * 60;
      _remainingSeconds += 5 * 60;
    });
  }

  Future<void> _handleSessionCompleted() async {
    _pauseTimer();
    HapticFeedback.heavyImpact();

    if (!_isBreak) {
      // انتهت جلسة التركيز
      if (_currentMode == TimerMode.pomodoro || _currentMode == TimerMode.rounds) {
        await _tts.speak('أحسنت! انتهت جلسة التركيز، حان وقت استراحة قصيرة.');
        setState(() {
          _isBreak = true;
          _totalSeconds = _currentMode.defaultBreakMinutes * 60;
          _remainingSeconds = _totalSeconds;
        });
        _startTimer();
      } else {
        await _tts.speak('رائع! اكتمل وقت الدراسة بنجاح.');
      }
    } else {
      // انتهت الاستراحة
      await _tts.speak('انتهت الاستراحة، هيا لنواصل التركيز.');
      setState(() {
        _isBreak = false;
        if (_currentMode == TimerMode.rounds) {
          _currentRound = (_currentRound < _totalRounds) ? _currentRound + 1 : 1;
        }
        _totalSeconds = _currentMode.defaultWorkMinutes * 60;
        _remainingSeconds = _totalSeconds;
      });
    }
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalSeconds > 0 ? (_remainingSeconds / _totalSeconds) : 0.0;
    final activeColor = _isBreak ? Colors.teal : _currentMode.themeColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('مؤقّت التركيز والدراسة', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // أزرار اختيار النمط بأشكال كبسولية أنيقة
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: TimerMode.values.map((mode) {
                    final isSel = _currentMode == mode;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _setMode(mode),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSel ? Theme.of(context).cardColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isSel
                                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 2))]
                                : [],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(mode.icon, size: 20, color: isSel ? mode.themeColor : Colors.grey),
                              const SizedBox(height: 4),
                              Text(
                                mode.label.split(' ').first,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                  color: isSel ? mode.themeColor : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 36),

              // الدائرة المركزية مع تدرج التقدم
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 250,
                      height: 250,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 14,
                        strokeCap: StrokeCap.round,
                        backgroundColor: activeColor.withValues(alpha: 0.12),
                        color: activeColor,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isBreak ? '☕ استراحة قصيرة' : '🎯 جلسة تركيز',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: activeColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatTime(_remainingSeconds),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                        if (_currentMode == TimerMode.rounds) ...[
                          const SizedBox(height: 4),
                          Text(
                            'الجولة $_currentRound من $_totalRounds',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // أزرار التحكم الرئيسية
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filledTonal(
                    iconSize: 28,
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'إعادة ضبط',
                    onPressed: _resetTimer,
                  ),
                  const SizedBox(width: 24),
                  FloatingActionButton.large(
                    elevation: 4,
                    backgroundColor: activeColor,
                    foregroundColor: Colors.white,
                    onPressed: _isRunning ? _pauseTimer : _startTimer,
                    child: Icon(_isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 44),
                  ),
                  const SizedBox(width: 24),
                  IconButton.filledTonal(
                    iconSize: 28,
                    icon: const Icon(Icons.more_time_rounded),
                    tooltip: 'إضافة 5 دقائق',
                    onPressed: _addExtraFiveMinutes,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // شريط نصائح دراسية سريع
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: activeColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.tips_and_updates_rounded, color: activeColor, size: 22),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'نصيحة: قسّم دراسة الكلمات إلى جلسات قصيرة لرفع كفاءة التثبيت في الذاكرة طويلة المدى.',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
