import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/design_system/app_audio_button.dart';
import 'package:deutsch_bilarabi/core/audio/offline_audio_dispatcher.dart';
import 'package:deutsch_bilarabi/core/audio/offline_audio_pool.dart';

class PhoneticsLabScreen extends StatefulWidget {
  const PhoneticsLabScreen({super.key});

  @override
  State<PhoneticsLabScreen> createState() => _PhoneticsLabScreenState();
}

class _PhoneticsLabScreenState extends State<PhoneticsLabScreen> {
  int? _currentlyPlayingIndex;
  bool _isPlaying = false;
  double _speechRate = 0.9;

  final List<Map<String, dynamic>> _sounds = [
    {
      "symbol": "ä / ö / ü",
      "ipa": "[ɛː] / [øː] / [yː]",
      "desc": "حروف التملق (Umlaut) وكيفية تدوير الشفاه بالألمانية",
      "lang": "الألمانية",
      "langCode": "de-DE",
      "hasAudio": true
    },
    {
      "symbol": "ñ",
      "ipa": "[ɲ]",
      "desc": "حرف النون المضخم في اللغة الإسبانية",
      "lang": "الإسبانية",
      "langCode": "es-ES",
      "hasAudio": true
    },
    {
      "symbol": "ğ",
      "ipa": "[ɰ]",
      "desc": "الحرف الصامت أو الناعم في اللغة التركية",
      "lang": "التركية",
      "langCode": "tr-TR",
      "hasAudio": false
    },
    {
      "symbol": "unverified",
      "ipa": "غير متوفر",
      "desc": "وصف غير متوفر",
      "lang": "لغة غير متوفرة",
      "langCode": "unverified",
      "hasAudio": false
    },
  ];

  @override
  void dispose() {
    OfflineAudioPool().stop();
    super.dispose();
  }

  Future<void> _playAudio(int index) async {
    if (_isPlaying) {
      OfflineAudioPool().stop();
      if (_currentlyPlayingIndex == index) {
        setState(() {
          _isPlaying = false;
          _currentlyPlayingIndex = null;
        });
        return;
      }
    }

    setState(() {
      _isPlaying = true;
      _currentlyPlayingIndex = index;
    });

    final item = _sounds[index];
    await OfflineAudioDispatcher.speakText(
      text: item['symbol'] as String,
      bcp47Locale: item['langCode'] as String,
      speechRate: _speechRate,
    );

    if (mounted) {
      setState(() {
        if (_currentlyPlayingIndex == index) {
          _isPlaying = false;
          _currentlyPlayingIndex = null;
        }
      });
    }
  }

  void _toggleSpeed() {
    setState(() {
      _speechRate = _speechRate == 0.9 ? 0.45 : 0.9;
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
          Tooltip(
            message: 'تغيير سرعة النطق',
            child: IconButton(
              icon: Icon(
                _speechRate == 0.9 ? Icons.speed : Icons.speed_outlined,
                semanticLabel: 'تغيير سرعة النطق',
              ),
              onPressed: _toggleSpeed,
            ),
          )
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
                final hasAudio = item['hasAudio'] as bool;
                final isCurrentPlaying =
                    _currentlyPlayingIndex == index && _isPlaying;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: AppBaseGlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF34D399).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item['symbol'] as String,
                                style: const TextStyle(
                                    color: Color(0xFF34D399),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text(
                                  item['ipa'] as String,
                                  style: const TextStyle(
                                      color: Color(0xFF6EE7B7), fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Semantics(
                            label: item['desc'] as String,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  item['lang'] as String,
                                  style: const TextStyle(
                                      color: Color(0xFF38BDF8), fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['desc'] as String,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.white, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (hasAudio)
                          AppAudioButton(
                            onPressed: () => _playAudio(index),
                            semanticLabel: 'استمع للفظ الصحيح',
                            isActive: isCurrentPlaying,
                            icon: isCurrentPlaying
                                ? FontAwesomeIcons.stop
                                : FontAwesomeIcons.volumeHigh,
                          )
                        else
                          const Tooltip(
                            message: 'النطق الصوتي غير متوفر حالياً',
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: FaIcon(
                                FontAwesomeIcons.microphoneSlash,
                                color: Colors.white38,
                                size: 20,
                              ),
                            ),
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
