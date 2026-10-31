import 'package:flutter/material.dart';

import '../../core/text/directional_text.dart';
import '../../features/pronunciation/domain/pronunciation_models.dart';
import '../shared/text/bidi_text.dart';

class PronunciationPerceptionCard extends StatelessWidget {
  const PronunciationPerceptionCard({
    super.key,
    required this.contrast,
    required this.options,
    required this.slow,
    required this.busy,
    required this.onSlowChanged,
    required this.onListen,
    required this.onChoose,
  });

  final PronunciationContrast contrast;
  final List<String> options;
  final bool slow;
  final bool busy;
  final ValueChanged<bool> onSlowChanged;
  final VoidCallback onListen;
  final ValueChanged<String> onChoose;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                contrast.titleAr,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                '1) استمع للكلمة المخفية. 2) اختر أي كلمة سمعت. '
                'لا يوجد إرسال صوت إلى خادم.',
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: busy ? null : onListen,
                icon: const Icon(Icons.volume_up_outlined),
                label: Text(busy ? 'جارٍ التشغيل...' : 'استمع'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('تشغيل بطيء للتدريب'),
                value: slow,
                onChanged: busy ? null : onSlowChanged,
              ),
              const SizedBox(height: 6),
              for (final option in options)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton(
                    onPressed: busy ? null : () => onChoose(option),
                    child: BidiText(
                      DirectionalText.german(
                        option,
                        semanticRole: LinguisticSemanticRole.word,
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
}

class PronunciationFeedbackCard extends StatelessWidget {
  const PronunciationFeedbackCard({
    super.key,
    required this.result,
    required this.coachingAr,
  });

  final PronunciationPerceptionResult result;
  final String coachingAr;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    result.correct ? Icons.check_circle : Icons.refresh,
                    color: result.correct ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.feedbackAr,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(coachingAr),
              const SizedBox(height: 10),
              BidiText(
                DirectionalText.german(
                  'Ziel: ${result.expectedToken}',
                  semanticRole: LinguisticSemanticRole.phonetic,
                ),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      );
}

class PronunciationProductionCard extends StatelessWidget {
  const PronunciationProductionCard({
    super.key,
    required this.targetToken,
    required this.busy,
    required this.feedback,
    required this.onCapture,
  });

  final String targetToken;
  final bool busy;
  final PronunciationProductionFeedback? feedback;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    final features = feedback?.features;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'الإنتاج المحلي',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'انطق الكلمة مرة واحدة. نحلل جودة الإشارة والتوقيت على الجهاز فقط؛ '
              'لا نحول النتيجة إلى درجة فونيمية مزيفة.',
            ),
            const SizedBox(height: 10),
            BidiText(
              DirectionalText.german(
                targetToken,
                semanticRole: LinguisticSemanticRole.word,
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: busy ? null : onCapture,
              icon: const Icon(Icons.mic_none_outlined),
              label: Text(
                busy ? 'جارٍ الالتقاط المحلي...' : 'افحص نطقي محليًا',
              ),
            ),
            if (feedback != null) ...[
              const SizedBox(height: 12),
              Text(feedback!.messageAr),
              if (features != null) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text('الصوت: ${features.voicedDurationMs} ms')),
                    Chip(
                      label: Text(
                        'RMS: ${(features.rms * 100).toStringAsFixed(1)}%',
                      ),
                    ),
                    Chip(
                      label: Text(
                        'ZCR: ${(features.zeroCrossingRate * 100).toStringAsFixed(1)}%',
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class PronunciationConfusionPanel extends StatelessWidget {
  const PronunciationConfusionPanel({
    super.key,
    required this.stats,
    required this.catalog,
  });

  final List<PronunciationConfusionStat> stats;
  final List<PronunciationContrast> catalog;

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.track_changes_outlined),
          title: Text('خريطة الالتباس الصوتي'),
          subtitle: Text('ستظهر هنا الأنماط المتكررة بعد عدة جولات.'),
        ),
      );
    }

    String titleFor(String id) {
      for (final contrast in catalog) {
        if (contrast.id == id) return contrast.titleAr;
      }
      return id;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'خريطة الالتباس الصوتي',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            for (final stat in stats.take(4))
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(titleFor(stat.contrastId)),
                subtitle: Text(
                  '${stat.mistakes} أخطاء من ${stat.attempts} محاولات',
                ),
                trailing: Text('${(stat.errorRate * 100).round()}%'),
              ),
          ],
        ),
      ),
    );
  }
}
