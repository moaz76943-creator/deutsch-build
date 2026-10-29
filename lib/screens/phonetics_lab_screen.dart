import 'dart:async';

import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/services/tts_service.dart';
import 'package:flutter/material.dart';

class PhoneticsLabScreen extends StatefulWidget {
  const PhoneticsLabScreen({super.key});

  @override
  State<PhoneticsLabScreen> createState() => _PhoneticsLabScreenState();
}

class _PhoneticsLabScreenState extends State<PhoneticsLabScreen> {
  static final List<Map<String, String>> _sounds = <Map<String, String>>[
    <String, String>{
      'symbol': 'ä / ö / ü',
      'speech': 'ä, ö, ü',
      'desc': 'حروف الأوملاوت الألمانية وكيف يتغير شكل الشفاه معها.',
      'lang': 'الألمانية',
      'code': 'de',
    },
    <String, String>{
      'symbol': 'ñ',
      'speech': 'ñ',
      'desc': 'الحرف ñ في الإسبانية ضمن التدريب على التمييز السمعي.',
      'lang': 'الإسبانية',
      'code': 'es',
    },
    <String, String>{
      'symbol': 'ğ',
      'speech': 'ğ',
      'desc': 'الحرف ğ في التركية؛ تحقيقه الصوتي يعتمد على السياق.',
      'lang': 'التركية',
      'code': 'tr',
    },
  ];

  late final TtsService _tts = TtsService(onStatus: _onTtsStatus);
  String? _activeKey;
  String? _pendingKey;
  bool _busy = false;

  void _onTtsStatus(
    TtsStatus status, {
    String? locale,
    String? message,
  }) {
    if (!mounted) return;
    if (status == TtsStatus.speaking) {
      setState(() {
        _activeKey = _pendingKey;
        _busy = false;
      });
      return;
    }
    if (status == TtsStatus.completed ||
        status == TtsStatus.stopped ||
        status == TtsStatus.voiceMissing ||
        status == TtsStatus.unsupportedLanguage ||
        status == TtsStatus.unavailable ||
        status == TtsStatus.error) {
      setState(() {
        _activeKey = null;
        _busy = false;
      });
    }
  }

  Future<void> _togglePlayback(Map<String, String> item) async {
    final key = item['code'];
    if (key == null || _busy) return;

    if (_activeKey == key) {
      await _tts.stop();
      return;
    }

    setState(() {
      _busy = true;
      _pendingKey = key;
    });

    final played = await _tts.speak(
      item['speech'] ?? item['symbol'] ?? '',
      languageCode: key,
    );
    if (!mounted) return;

    if (!played) {
      setState(() {
        _activeKey = null;
        _busy = false;
      });
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'الصوت المحلي غير متاح لهذه اللغة. يبقى الشرح النصي متاحًا.',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    unawaited(_tts.dispose());
    super.dispose();
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
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              AppBaseGlassCard(
                padding: const EdgeInsets.all(14),
                child: Text(
                  'الصوت هنا من محرك الجهاز المحلي للمساعدة السمعية فقط. '
                  'وجود صوت TTS لا يثبت جودة النطق ولا يُستخدم كتقييم للدقة.',
                  style: AppTypography.body.copyWith(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              for (final item in _sounds)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: AppBaseGlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF34D399)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item['symbol']!,
                            style: const TextStyle(
                              color: Color(0xFF34D399),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                item['lang']!,
                                style: const TextStyle(
                                  color: Color(0xFF38BDF8),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['desc']!,
                                style: AppTypography.body.copyWith(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: _activeKey == item['code']
                              ? 'إيقاف الصوت'
                              : 'تشغيل الصوت المحلي',
                          onPressed: _busy
                              ? null
                              : () => unawaited(_togglePlayback(item)),
                          icon: Icon(
                            _activeKey == item['code']
                                ? Icons.stop_circle_rounded
                                : Icons.volume_up_rounded,
                            color: _busy
                                ? Colors.white38
                                : const Color(0xFFF39C6B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
