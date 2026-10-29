import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/core/audio/offline_audio_dispatcher.dart';

class PhoneticEntry {
  final String grapheme;
  final String? ipa;
  final String? transliteration;
  final String description;
  final String languageName;
  final String bcp47Locale;
  final bool hasVerifiedAudio;

  const PhoneticEntry({
    required this.grapheme,
    this.ipa,
    this.transliteration,
    required this.description,
    required this.languageName,
    required this.bcp47Locale,
    required this.hasVerifiedAudio,
  });

  String? get sanitizedIpa {
    if (ipa == null) return null;
    if (!ipa!.startsWith('/') || !ipa!.endsWith('/')) {
      return 'Invalid IPA format detected';
    }
    return ipa;
  }
}

class PhoneticsLabScreen extends StatefulWidget {
  const PhoneticsLabScreen({super.key});

  @override
  State<PhoneticsLabScreen> createState() => _PhoneticsLabScreenState();
}

class _PhoneticsLabScreenState extends State<PhoneticsLabScreen> {
  final List<PhoneticEntry> sounds = const [
    PhoneticEntry(
      grapheme: "ä / ö / ü",
      ipa: "/ɛ/ /ø/ /y/",
      transliteration: "ae / oe / ue",
      description: "حروف الإمالة (Umlaut) وكيفية تدوير الشفاه بالألمانية",
      languageName: "الألمانية",
      bcp47Locale: "de-DE",
      hasVerifiedAudio: true,
    ),
    PhoneticEntry(
      grapheme: "ñ",
      ipa: "/ɲ/",
      transliteration: "ny",
      description: "حرف النون المضخم في اللغة الإسبانية",
      languageName: "الإسبانية",
      bcp47Locale: "es-ES",
      hasVerifiedAudio: true,
    ),
    PhoneticEntry(
      grapheme: "ğ",
      ipa: "/ː/",
      transliteration: "gh",
      description: "الحرف الصامت أو الناعم في اللغة التركية",
      languageName: "التركية",
      bcp47Locale: "tr-TR",
      hasVerifiedAudio: false,
    ),
    PhoneticEntry(
      grapheme: "ض",
      ipa: "/dˤ/",
      transliteration: "d",
      description: "حرف الضاد المفخم في اللغة العربية",
      languageName: "العربية",
      bcp47Locale: "ar-SA",
      hasVerifiedAudio: true,
    ),
    PhoneticEntry(
      grapheme: "long text",
      ipa: "invalid",
      transliteration: "test",
      description: "This is an extremely long description that should properly wrap within the constrained space of the phonetic entry tile. It shouldn't overflow or cause a rendering error in the list view layout.",
      languageName: "English",
      bcp47Locale: "en-US",
      hasVerifiedAudio: true,
    ),
  ];

  int? _playingIndex;
  bool _isPlaying = false;

  @override
  void dispose() {
    OfflineAudioDispatcher.stopCurrentAudio();
    super.dispose();
  }

  Future<void> _play(int index, double speed) async {
    if (_isPlaying) {
      OfflineAudioDispatcher.stopCurrentAudio();
    }
    final entry = sounds[index];
    if (!entry.hasVerifiedAudio) return;

    if (mounted) {
      setState(() {
        _playingIndex = index;
        _isPlaying = true;
      });
    }

    await OfflineAudioDispatcher.speakText(
      text: entry.grapheme,
      bcp47Locale: entry.bcp47Locale,
      speechRate: speed,
    );

    if (mounted && _playingIndex == index) {
      setState(() {
        _isPlaying = false;
        _playingIndex = null;
      });
    }
  }

  void _stop() {
    OfflineAudioDispatcher.stopCurrentAudio();
    if (mounted) {
      setState(() {
        _isPlaying = false;
        _playingIndex = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('معمل تدريب الصوتيات ومخارج الحروف'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: sounds.length,
              itemBuilder: (context, index) {
                final item = sounds[index];
                final isCurrentPlaying = _playingIndex == index && _isPlaying;

                return Semantics(
                  label: 'صوت ${item.grapheme} في ${item.languageName}',
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: AppBaseGlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF34D399).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Text(
                                    item.grapheme,
                                    style: const TextStyle(color: Color(0xFF34D399), fontSize: 24, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      item.languageName,
                                      style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.description,
                                      style: AppTypography.body.copyWith(color: Colors.white, fontSize: 14),
                                    ),
                                    if (item.sanitizedIpa != null) ...[
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Directionality(
                                              textDirection: TextDirection.ltr,
                                              child: Text(
                                                'IPA: ${item.sanitizedIpa}',
                                                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontFamily: 'monospace'),
                                              ),
                                            ),
                                          ),
                                          if (item.transliteration != null)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Directionality(
                                                textDirection: TextDirection.ltr,
                                                child: Text(
                                                  'Trans: ${item.transliteration}',
                                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                    if (!item.hasVerifiedAudio)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          'النطق غير متوفر حالياً',
                                          style: TextStyle(color: Colors.orangeAccent, fontSize: 12),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (item.hasVerifiedAudio) ...[
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (isCurrentPlaying)
                                  IconButton(
                                    icon: const Icon(Icons.stop, color: Colors.redAccent),
                                    onPressed: _stop,
                                    tooltip: 'إيقاف',
                                  )
                                else ...[
                                  IconButton(
                                    icon: const Icon(Icons.play_arrow, color: Color(0xFF34D399)),
                                    onPressed: () => _play(index, 1.0),
                                    tooltip: 'تشغيل',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.slow_motion_video, color: Color(0xFF38BDF8)),
                                    onPressed: () => _play(index, 0.5),
                                    tooltip: 'تشغيل ببطء',
                                  ),
                                ]
                              ],
                            ),
                          ]
                        ],
                      ),
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
