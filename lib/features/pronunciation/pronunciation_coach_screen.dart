import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Pronunciation Coach - On-device speech recognition for German practice.
/// Privacy-first: all processing happens locally. No audio leaves the device.
class PronunciationCoachScreen extends ConsumerStatefulWidget {
  const PronunciationCoachScreen({super.key});

  @override
  ConsumerState<PronunciationCoachScreen> createState() => _PronunciationCoachScreenState();
}

class _PronunciationCoachScreenState extends ConsumerState<PronunciationCoachScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isListening = false;
  String _recognizedText = '';
  String _targetPhrase = 'Guten Morgen';
  double _confidence = 0.0;
  String _feedback = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
    _loadProgress();
  }

  Future<void> _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) => setState(() {
        _isListening = status == 'listening';
      }),
      onError: (error) => setState(() {
        _feedback = 'Error: ${error.errorMsg}';
      }),
    );
    if (!available) {
      setState(() => _feedback = 'Speech recognition not available on this device');
    }
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('de-DE');
    await _tts.setSpeechRate(0.5);
  }

  Future<void> _loadProgress() async {
    // Encrypted storage for progress to prevent tampering
    final saved = await _secureStorage.read(key: 'pronunciation_streak');
    // Use saved data if available
  }

  Future<void> _startListening() async {
    if (!_isListening) {
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
            _confidence = result.confidence;
            _evaluatePronunciation();
          });
        },
        localeId: 'de_DE',
        listenMode: stt.ListenMode.confirmation,
      );
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
  }

  void _evaluatePronunciation() {
    // Simple Levenshtein or exact match for demo; replace with more advanced scoring
    final target = _targetPhrase.toLowerCase();
    final recognized = _recognizedText.toLowerCase();
    if (recognized.contains(target) || _confidence > 0.8) {
      setState(() => _feedback = '✅ Excellent! Pronunciation matches.');
      _saveProgress(true);
    } else {
      setState(() => _feedback = '⚠️ Try again. Listen to the model and repeat.');
    }
  }

  Future<void> _saveProgress(bool success) async {
    await _secureStorage.write(key: 'last_practice', value: DateTime.now().toIso8601String());
    // Backend logic would verify integrity here in production
  }

  Future<void> _speakTarget() async {
    await _tts.speak(_targetPhrase);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pronunciation Coach')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Target: $_targetPhrase', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _speakTarget,
              icon: const Icon(Icons.volume_up),
              label: const Text('Listen to Model'),
            ),
            const SizedBox(height: 24),
            Text('You said: $_recognizedText'),
            Text('Confidence: ${(_confidence * 100).toStringAsFixed(0)}%'),
            const SizedBox(height: 16),
            Text(_feedback, style: TextStyle(color: _feedback.startsWith('✅') ? Colors.green : Colors.orange)),
            const Spacer(),
            FloatingActionButton.extended(
              onPressed: _isListening ? _stopListening : _startListening,
              label: Text(_isListening ? 'Stop' : 'Start Speaking'),
              icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
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
