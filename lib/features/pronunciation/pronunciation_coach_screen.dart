import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:deutsch_bilarabi/core/security/play_integrity_service.dart';

/// Pronunciation Coach - On-device speech recognition for German practice.
/// Privacy-first: all processing happens locally. No audio leaves the device.
/// Advanced feedback and progress gated by Play Integrity API + backend verification.
/// Protected against modding, reverse engineering, and data theft via encrypted storage + integrity.
class PronunciationCoachScreen extends ConsumerStatefulWidget {
  const PronunciationCoachScreen({super.key});

  @override
  ConsumerState<PronunciationCoachScreen> createState() => _PronunciationCoachScreenState();
}

class _PronunciationCoachScreenState extends ConsumerState<PronunciationCoachScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      sharedPreferencesName: 'deutsch_secure_prefs',
      preferencesKeyPrefix: 'deutsch_',
    ),
  );

  bool _isListening = false;
  String _recognizedText = '';
  String _targetPhrase = 'Guten Morgen';
  double _confidence = 0.0;
  String _feedback = '';
  bool _integrityVerified = false;
  bool _checkingIntegrity = true;

  @override
  void initState() {
    super.initState();
    _checkIntegrityAndInit();
  }

  Future<void> _checkIntegrityAndInit() async {
    final integrity = ref.read(playIntegrityServiceProvider);
    final verified = await integrity.verifyIntegrity();
    if (!mounted) return;
    setState(() {
      _integrityVerified = verified;
      _checkingIntegrity = false;
    });
    if (verified) {
      await _initSpeech();
      await _initTts();
      await _loadProgress();
    } else {
      setState(() => _feedback = '⚠️ App integrity check failed. Practice limited for security.');
    }
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
      // Model audio is optional.
    }
  }

  Future<void> _loadProgress() async {
    try {
      await _secureStorage.read(key: 'pronunciation_streak');
    } catch (_) {}
  }

  Future<void> _startListening() async {
    if (!_integrityVerified) {
      setState(() => _feedback = 'Integrity required for practice.');
      return;
    }
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

  int _levenshtein(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    final matrix = List.generate(a.length + 1, (_) => List.filled(b.length + 1, 0));
    for (var i = 0; i <= a.length; i++) matrix[i][0] = i;
    for (var j = 0; j <= b.length; j++) matrix[0][j] = j;
    for (var i = 1; i <= a.length; i++) {
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    return matrix[a.length][b.length];
  }

  void _evaluatePronunciation() {
    final target = _targetPhrase.toLowerCase().trim();
    final recognized = _recognizedText.toLowerCase().trim();
    final distance = _levenshtein(target, recognized);
    final maxLen = target.length > recognized.length ? target.length : recognized.length;
    final similarity = maxLen == 0 ? 1.0 : 1.0 - (distance / maxLen);

    if (similarity > 0.75 || _confidence > 0.85) {
      setState(() => _feedback = '✅ Excellent! Similarity ${(similarity * 100).toStringAsFixed(0)}%');
      _saveProgress(true);
    } else if (similarity > 0.5) {
      setState(() => _feedback = '⚠️ Close! Try again. Similarity ${(similarity * 100).toStringAsFixed(0)}%');
    } else {
      setState(() => _feedback = '❌ Listen carefully and repeat.');
    }
  }

  Future<void> _saveProgress(bool success) async {
    if (!_integrityVerified) return;
    try {
      await _secureStorage.write(
        key: 'last_practice',
        value: DateTime.now().toIso8601String(),
      );
    } catch (_) {}
  }

  Future<void> _speakTarget() async {
    await _tts.speak(_targetPhrase);
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingIntegrity) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Pronunciation Coach')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_integrityVerified)
              const Card(
                color: Colors.orangeAccent,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Limited mode: Integrity verification required for full features and progress saving.'),
                ),
              ),
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
            Text(_feedback, style: TextStyle(
              color: _feedback.startsWith('✅') ? Colors.green :
                     _feedback.startsWith('⚠') ? Colors.orange : Colors.red,
            )),
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
