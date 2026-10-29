import 'package:flutter/material.dart';

import '../../../../core/content_contract.dart';
import '../../../../design_system/app_colors.dart';
import '../../../../design_system/app_glass_card.dart';
import '../../../../design_system/app_typography.dart';
import '../../../../models/learner.dart';
import '../../application/daily_drill_controller.dart';
import '../../domain/daily_drill_models.dart';
import '../widgets/drill_completion_summary_widget.dart';
import '../widgets/quick_card_flip_widget.dart';

class DailyDrillScreen extends StatefulWidget {
  const DailyDrillScreen({
    required this.controller,
    required this.learnerState,
    required this.corpus,
    this.limit = 10,
    this.sourceLanguageCode = 'de',
    this.translationLanguageCode = 'ar',
    super.key,
  });

  final DailyDrillController controller;
  final LearnerState learnerState;
  final List<LearningContent> corpus;
  final int limit;
  final String sourceLanguageCode;
  final String translationLanguageCode;

  @override
  State<DailyDrillScreen> createState() => _DailyDrillScreenState();
}

class _DailyDrillScreenState extends State<DailyDrillScreen> {
  late DateTime _cardStartedAt;

  @override
  void initState() {
    super.initState();
    _cardStartedAt = DateTime.now();
    widget.controller.start(
      learnerState: widget.learnerState,
      corpus: widget.corpus,
      now: _cardStartedAt,
      limit: widget.limit,
    );
  }

  Future<void> _grade(bool correct) async {
    final elapsed = DateTime.now().difference(_cardStartedAt);
    try {
      await widget.controller.gradeCurrent(
        correct: correct,
        elapsed: elapsed,
      );
      if (!mounted) return;
      setState(() {
        _cardStartedAt = DateTime.now();
      });
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر حفظ المراجعة الآن. حاول مرة أخرى.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final state = widget.controller.state;
        return Scaffold(
          appBar: AppBar(
            title: const Text('المراجعة اليومية السريعة'),
          ),
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: SafeArea(
              child: _bodyFor(state),
            ),
          ),
        );
      },
    );
  }

  Widget _bodyFor(DailyDrillState state) {
    if (state.status == DailyDrillStatus.idle) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == DailyDrillStatus.completed) {
      final summary = state.summary ??
          const DrillResultSummary(
            reviewedCards: 0,
            correctCards: 0,
            totalSeconds: 0,
            currentStreak: 0,
            sessionXp: 0,
          );
      return ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          DrillCompletionSummaryWidget(summary: summary),
        ],
      );
    }

    final current = state.currentItem;
    if (current == null) {
      return const Center(child: Text('لا توجد بطاقة مراجعة نشطة.'));
    }
    final session = state.session!;
    final total = session.items.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _DailyDrillHeader(
          current: state.currentIndex + 1,
          total: total,
          correct: state.correctCount,
          streak: state.currentStreak,
        ),
        const SizedBox(height: 14),
        QuickCardFlipWidget(
          review: current,
          revealed: state.revealed,
          onFlip: state.busy ? null : widget.controller.reveal,
          sourceLanguageCode: widget.sourceLanguageCode,
          translationLanguageCode: widget.translationLanguageCode,
        ),
        const SizedBox(height: 14),
        if (!state.revealed)
          AppGlassCard(
            borderColor: AppColors.primary.withAlpha(72),
            child: Text(
              'حاول تذكّر المعنى أولًا، ثم اقلب البطاقة.',
              textAlign: TextAlign.center,
              style: AppTypography.body,
            ),
          )
        else
          _RecallActions(
            busy: state.busy,
            onForgot: () => _grade(false),
            onRemembered: () => _grade(true),
          ),
      ],
    );
  }
}

class _DailyDrillHeader extends StatelessWidget {
  const _DailyDrillHeader({
    required this.current,
    required this.total,
    required this.correct,
    required this.streak,
  });

  final int current;
  final int total;
  final int correct;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : current / total;
    return AppGlassCard(
      borderColor: AppColors.primary.withAlpha(72),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'بطاقة $current من $total',
                  style: AppTypography.label,
                ),
              ),
              Icon(
                Icons.local_fire_department_rounded,
                color: AppColors.streak,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                '$streak',
                style: AppTypography.label.copyWith(
                  color: AppColors.streak,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0).toDouble(),
            minHeight: 7,
            borderRadius: BorderRadius.circular(8),
            color: AppColors.primary,
          ),
          const SizedBox(height: 7),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'صحيح حتى الآن: $correct',
              style: AppTypography.label,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecallActions extends StatelessWidget {
  const _RecallActions({
    required this.busy,
    required this.onForgot,
    required this.onRemembered,
  });

  final bool busy;
  final VoidCallback onForgot;
  final VoidCallback onRemembered;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      borderColor: AppColors.mastery.withAlpha(70),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'كيف كان تذكّرك؟',
            textAlign: TextAlign.center,
            style: AppTypography.title,
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: busy ? null : onForgot,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('نسيت'),
              ),
              FilledButton.icon(
                onPressed: busy ? null : onRemembered,
                icon: busy
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded),
                label: const Text('تذكرت'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
