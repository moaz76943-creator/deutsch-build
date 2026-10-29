import 'package:flutter/material.dart';

import '../../core/text/directional_text.dart';
import '../../features/commute/domain/commute_models.dart';
import '../../models/content.dart';
import '../shared/text/bidi_text.dart';

class CommuteNowPlayingCard extends StatelessWidget {
  const CommuteNowPlayingCard({
    super.key,
    required this.review,
    required this.targetLanguageCode,
    required this.sourceLanguageCode,
    required this.position,
    required this.total,
    required this.status,
  });

  final CommuteReviewItem<ContentItem> review;
  final String targetLanguageCode;
  final String sourceLanguageCode;
  final int position;
  final int total;
  final String status;

  @override
  Widget build(BuildContext context) => Card(
        color: const Color(0xFF171717),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'مراجعة $position من $total',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              BidiText(
                DirectionalText.forLanguage(
                  review.item.sourceText,
                  languageCode: targetLanguageCode,
                  semanticRole: LinguisticSemanticRole.word,
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              BidiText(
                DirectionalText.forLanguage(
                  review.item.translationText,
                  languageCode: sourceLanguageCode,
                  semanticRole: LinguisticSemanticRole.translation,
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                review.isListening ? 'Facet: listening' : 'Facet: meaning',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 12),
              Text(
                status,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
}

class CommutePlaybackControls extends StatelessWidget {
  const CommutePlaybackControls({
    super.key,
    required this.playing,
    required this.busy,
    required this.onPlay,
    required this.onPause,
    required this.onKnown,
    required this.onUnknown,
  });

  final bool playing;
  final bool busy;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onKnown;
  final VoidCallback onUnknown;

  static const double _controlHeight = 72;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: _controlHeight,
                  child: FilledButton.icon(
                    onPressed: busy || playing ? null : onPlay,
                    icon: const Icon(Icons.play_arrow, size: 34),
                    label: const Text(
                      'تشغيل',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: _controlHeight,
                  child: FilledButton.tonalIcon(
                    onPressed: playing ? onPause : null,
                    icon: const Icon(Icons.pause, size: 34),
                    label: const Text(
                      'إيقاف مؤقت',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: _controlHeight,
            child: FilledButton.icon(
              onPressed: busy ? null : onKnown,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0B6E3C),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.check_circle_outline, size: 32),
              label: const Text(
                'أعرفها',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: _controlHeight,
            child: FilledButton.icon(
              onPressed: busy ? null : onUnknown,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF9B1C1C),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.replay_outlined, size: 32),
              label: const Text(
                'لا أعرفها',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      );
}

class CommuteEmptyState extends StatelessWidget {
  const CommuteEmptyState({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 72),
              SizedBox(height: 16),
              Text(
                'لا توجد مراجعات معنى أو استماع مستحقة الآن.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      );
}
