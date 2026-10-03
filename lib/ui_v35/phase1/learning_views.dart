import 'package:flutter/material.dart';

import 'learning_view_models.dart';
import '../../features/audio/data/native_tts_engine.dart';

final class TodayHomeView extends StatelessWidget {
  final TodayHomeViewModel model;

  const TodayHomeView({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final safeGoal = model.dailyGoal <= 0 ? 1 : model.dailyGoal;
    final progress =
        (model.completedToday / safeGoal).clamp(0.0, 1.0).toDouble();

    return Padding(
      key: const Key('phase1-today-home'),
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(model.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text('لديك ${model.dueCount} عناصر للمراجعة'),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 8),
          Text('${model.completedToday} / ${model.dailyGoal}'),
        ],
      ),
    );
  }
}

final class StudyCardView extends StatefulWidget {
  final StudyCardViewModel model;

  const StudyCardView({super.key, required this.model});

  @override
  State<StudyCardView> createState() => _StudyCardViewState();
}

class _StudyCardViewState extends State<StudyCardView> {
  late final NativeTtsEngine _tts;

  @override
  void initState() {
    super.initState();
    _tts = NativeTtsEngine();
  }

  @override
  void dispose() {
    // _tts.dispose(); // Do not dispose singleton here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (widget.model.prompt.isNotEmpty) Text(widget.model.prompt),
            const SizedBox(height: 12),
            Text(
              widget.model.sourceText,
              key: const Key('phase1-study-source'),
              textDirection: TextDirection.rtl,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.model.targetText,
                    key: const Key('phase1-study-target'),
                    textDirection: TextDirection.ltr,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up),
                  onPressed: () => _tts.speak(widget.model.targetText),
                  tooltip: 'استمع',
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: widget.model.progress.clamp(0.0, 1.0).toDouble(),
            ),
          ],
        ),
      ),
    );
  }
}

final class ReviewQueueView extends StatelessWidget {
  final ReviewQueueViewModel model;

  const ReviewQueueView({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('phase1-review-queue'),
      mainAxisSize: MainAxisSize.min,
      children: model.items
          .map(
            (item) => ListTile(
              key: ValueKey<String>(item.id),
              title: Text(item.targetText, textDirection: TextDirection.ltr),
              subtitle: Text(item.sourceText, textDirection: TextDirection.rtl),
              trailing: Text(item.dueLabel),
            ),
          )
          .toList(growable: false),
    );
  }
}
