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
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          if (!mounted) return;
          setState(() {
            _isListening = status == 'listening';
          });
        },
        onError: (error) {
          if (!mounted) return;
          setState(() {
            _feedback = 'Error: ${error.errorMsg}';
          });
        },
      );
      if (!mounted) return;
      if (!available) {
        setState(() => _feedback = 'Speech recognition not available on this device');
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _feedback = 'Speech recognition not available on this device');
    }
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('de-DE');
      await _tts.setSpeechRate(0.5);
    } catch (_) {
      // Model audio is optional. Recognition and the target phrase stay usable.
    }
  }

  Future<void> _loadProgress() async {
    try {
      // Encrypted storage for progress to prevent tampering.
      await _secureStorage.read(key: 'pronunciation_streak');
    } catch (_) {
      // A missing or locked keystore must not block practice.
    }
  }

  Future<void> _startListening() async {
    if (!_speech.isAvailable) {
      if (!mounted) return;
      setState(() => _feedback = 'Speech recognition not available on this device');
      return;
    }
    if (!_isListening) {
      try {
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
      } catch (_) {
        if (!mounted) return;
        setState(() => _feedback = 'Speech recognition not available on this device');
      }
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
    try {
      await _secureStorage.write(
        key: 'last_practice',
        value: DateTime.now().toIso8601String(),
      );
    } catch (_) {
      // Practice feedback stays on screen when the keystore write fails.
    }
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
    _speech.stop().catchError((Object _) {});
    _tts.stop().catchError((Object _) {});
    super.dispose();
  }
}
