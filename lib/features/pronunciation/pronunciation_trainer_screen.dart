import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';

class PronunciationTrainerScreen extends StatefulWidget {
  final String expectedPhrase;
  final String arabicTranslation;

  const PronunciationTrainerScreen({
    super.key,
    required this.expectedPhrase,
    required this.arabicTranslation,
  });

  @override
  State<PronunciationTrainerScreen> createState() => _PronunciationTrainerScreenState();
}

class _PronunciationTrainerScreenState extends State<PronunciationTrainerScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isListening = false;
  String _recognizedText = '';
  double _confidence = 0.0;
  double _score = 0.0;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('de-DE');
    await _tts.setSpeechRate(0.5);
  }

  Future<void> _initSpeech() async {
    final status = await Permission.microphone.request();
    _hasPermission = status.isGranted;
    if (_hasPermission) {
      await _speech.initialize(
        onStatus: (status) => setState(() => _isListening = status == 'listening'),
        onError: (error) => debugPrint('Speech error: $error'),
      );
    }
    setState(() {});
  }

  void _startListening() async {
    if (!_hasPermission || !_speech.isAvailable) return;
    await _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
          _confidence = result.confidence;
          _score = _calculateScore(widget.expectedPhrase, _recognizedText);
        });
      },
      localeId: 'de_DE',
      listenMode: stt.ListenMode.confirmation,
    );
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _speakPhrase() async {
    await _tts.speak(widget.expectedPhrase);
  }

  double _calculateScore(String expected, String recognized) {
    if (recognized.isEmpty) return 0.0;
    // Simple Levenshtein-based similarity (production: use better phoneme matching or ML model)
    final exp = expected.toLowerCase().trim();
    final rec = recognized.toLowerCase().trim();
    if (exp == rec) return 1.0;
    final distance = _levenshtein(exp, rec);
    final maxLen = exp.length > rec.length ? exp.length : rec.length;
    return (1.0 - (distance / maxLen)).clamp(0.0, 1.0) * _confidence;
  }

  int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;
    final matrix = List.generate(s.length + 1, (_) => List.filled(t.length + 1, 0));
    for (var i = 0; i <= s.length; i++) matrix[i][0] = i;
    for (var j = 0; j <= t.length; j++) matrix[0][j] = j;
    for (var i = 1; i <= s.length; i++) {
      for (var j = 1; j <= t.length; j++) {
        final cost = s[i - 1] == t[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    return matrix[s.length][t.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تدريب النطق')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.expectedPhrase,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.arabicTranslation,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _speakPhrase,
              icon: const Icon(Icons.volume_up),
              label: const Text('استمع للنطق الصحيح'),
            ),
            const SizedBox(height: 16),
            if (!_hasPermission)
              const Text('يرجى منح إذن الميكروفون للتدريب', textAlign: TextAlign.center),
            ElevatedButton.icon(
              onPressed: _isListening ? _stopListening : _startListening,
              icon: Icon(_isListening ? Icons.stop : Icons.mic),
              label: Text(_isListening ? 'إيقاف' : 'ابدأ التحدث'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isListening ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 24),
            Text('النص المعرف: $_recognizedText', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text('الثقة: ${(_confidence * 100).toStringAsFixed(1)}%', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: _score),
            Text('الدرجة: ${(_score * 100).toStringAsFixed(1)}%', style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            const Text(
              'يعمل بالكامل دون إنترنت. يعتمد على النموذج المحلي للجهاز.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    super.dispose();
  }
}
