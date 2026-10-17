import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/design_system/app_audio_button.dart';
import 'package:deutsch_bilarabi/core/audio/offline_audio_dispatcher.dart';
import 'package:deutsch_bilarabi/core/linguistics/phonetic_token.dart';

class PhoneticsLabScreen extends StatefulWidget {
  const PhoneticsLabScreen({super.key});

  @override
  State<PhoneticsLabScreen> createState() => _PhoneticsLabScreenState();
}

class _PhoneticsLabScreenState extends State<PhoneticsLabScreen> {
  int? _activePlayingIndex;
  double _speechRate = 0.8;

  final List<Map<String, dynamic>> _sounds = [
    {
      "token": const PhoneticToken(
        rawText: "ä / ö / ü",
        ipaRepresentation: "ɛ / ø / y",
        audioAssetKey: "ä / ö / ü",
      ),
      "desc": "حروف التملق (Umlaut) وكيفية تدوير الشفاه بالألمانية",
      "lang": "الألمانية",
      "locale": "de-DE",
      "isVerified": true,
    },
    {
      "token": const PhoneticToken(
        rawText: "ñ",
        ipaRepresentation: "ɲ",
        audioAssetKey: "ñ",
      ),
      "desc": "حرف النون المضخم في اللغة الإسبانية",
      "lang": "الإسبانية",
      "locale": "es-ES",
      "isVerified": true,
    },
    {
      "token": const PhoneticToken(
        rawText: "ğ",
        ipaRepresentation: "ː",
        audioAssetKey: "ğ",
      ),
      "desc": "الحرف الصامت أو الناعم في اللغة التركية",
      "lang": "التركية",
      "locale": "tr-TR",
      "isVerified": true,
    },
    {
      "token": const PhoneticToken(
        rawText: "unverified",
        ipaRepresentation: "?",
        audioAssetKey: "none",
      ),
      "desc": "نطق غير مدعوم أو غير موثق بعد",
      "lang": "مجهولة",
      "locale": "un-UN",
      "isVerified": false,
    },
  ];

  @override
  void dispose() {
    if (_activePlayingIndex != null) {
      OfflineAudioDispatcher.stopCurrentAudio();
    }
    super.dispose();
  }

  Future<void> _playAudio(int index) async {
    if (_activePlayingIndex != null) {
      OfflineAudioDispatcher.stopCurrentAudio();
    }

    if (!mounted) return;

    setState(() {
      _activePlayingIndex = index;
    });

    try {
      final locale = _sounds[index]['locale'] as String;
      final rawText = (_sounds[index]['token'] as PhoneticToken).rawText;

      await OfflineAudioDispatcher.speakText(
        text: rawText,
        bcp47Locale: locale,
        speechRate: _speechRate,
      );
    } finally {
      if (mounted && _activePlayingIndex == index) {
        setState(() {
          _activePlayingIndex = null;
        });
      }
    }
  }

  void _cycleSpeechRate() {
    setState(() {
      if (_speechRate == 0.8) {
        _speechRate = 0.5;
      } else if (_speechRate == 0.5) {
        _speechRate = 1.2;
      } else {
        _speechRate = 0.8;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('معمل تدريب الصوتيات ومخارج الحروف'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _speechRate == 1.2
                  ? Icons.speed
                  : _speechRate == 0.5
                      ? Icons.slow_motion_video
                      : Icons.play_circle_outline,
            ),
            tooltip: 'تغيير سرعة النطق',
            onPressed: _cycleSpeechRate,
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: _sounds.length,
              itemBuilder: (context, index) {
                final item = _sounds[index];
                final PhoneticToken token = item['token'];
                final bool isVerified = item['isVerified'];
                final isActive = _activePlayingIndex == index;
                final isAnyPlaying = _activePlayingIndex != null;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: AppBaseGlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isVerified
                                ? const Color(0xFF34D399).withValues(alpha: 0.15)
                                : Colors.redAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                token.rawText,
                                style: TextStyle(
                                  color: isVerified ? const Color(0xFF34D399) : Colors.redAccent,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isVerified ? '[${token.ipaRepresentation}]' : 'غير متوفر',
                                style: TextStyle(
                                  color: (isVerified ? const Color(0xFF34D399) : Colors.redAccent).withValues(alpha: 0.8),
                                  fontSize: 14,
                                  fontFamily: 'Noto Sans',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                item['lang']!,
                                style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['desc']!,
                                style: AppTypography.body.copyWith(color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (isVerified)
                          AppAudioButton(
                            semanticLabel: 'استمع إلى النطق',
                            isActive: isActive,
                            isBusy: isAnyPlaying && !isActive,
                            onPressed: isAnyPlaying ? null : () => _playAudio(index),
                          )
                        else
                           const Tooltip(
                             message: 'النطق غير متوفر',
                             child: Icon(Icons.volume_off, color: Colors.white38),
                           ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
