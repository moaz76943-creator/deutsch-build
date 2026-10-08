import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart' hide AppDirectionalText;
import '../application/mobility_master_orchestrator.dart';
import '../domain/mobility_models.dart';

class MobilityScreen extends StatelessWidget {
  const MobilityScreen({required this.orchestrator, super.key});

  final MobilityMasterOrchestrator orchestrator;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: AppDirectionalText(
            'Mobilität & Verkehr',
            languageCode: 'de',
            style: AppTypography.title,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: AnimatedBuilder(
              animation: orchestrator,
              builder: (context, _) {
                final items = orchestrator.visibleItems;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _IntroCard(),
                    const SizedBox(height: 14),
                    _SearchCard(orchestrator: orchestrator),
                    const SizedBox(height: 14),
                    _LevelFilterCard(orchestrator: orchestrator),
                    const SizedBox(height: 14),
                    _PlatformPanicCard(orchestrator: orchestrator),
                    const SizedBox(height: 14),
                    _AgentOverviewCard(),
                    const SizedBox(height: 14),
                    if (items.isEmpty)
                      _EmptyResultCard()
                    else
                      for (var index = 0; index < items.length; index++) ...[
                        _MobilityLessonCard(item: items[index]),
                        if (index != items.length - 1)
                          const SizedBox(height: 12),
                      ],
                  ],
                );
              },
            ),
          ),
        ),
      );
}

class _IntroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppDirectionalText(
              'Mobility Master Hub',
              languageCode: 'de',
              style: AppTypography.display,
            ),
            const SizedBox(height: 8),
            AppDirectionalText(
              'تدريب عملي على Deutsche Bahn وÖPNV: تغيير الرصيف، التأخير، حجز المقعد، التذاكر المحلية، Deutschlandticket ووصلات الحافلة والمترو.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

class _SearchCard extends StatelessWidget {
  const _SearchCard({required this.orchestrator});

  final MobilityMasterOrchestrator orchestrator;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.secondary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppDirectionalText(
              'Schnellsuche',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: 8),
            AppDirectionalText(
              'ابحث بالألمانية أو العربية داخل مواقف النقل.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(height: 10),
            Directionality(
              textDirection: TextDirection.ltr,
              child: TextField(
                onChanged: orchestrator.search,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Gleis, Verspätung, Bus, Deutschlandticket ...',
                  suffixIcon: orchestrator.query.isEmpty
                      ? const Icon(Icons.search_rounded)
                      : IconButton(
                          onPressed: orchestrator.clearSearch,
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
            ),
          ],
        ),
      );
}

class _LevelFilterCard extends StatelessWidget {
  const _LevelFilterCard({required this.orchestrator});

  final MobilityMasterOrchestrator orchestrator;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.achievement,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppDirectionalText(
              'Sprachniveau',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: 10),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: AppDirectionalText(
                      'Alle',
                      languageCode: 'de',
                      style: AppTypography.label,
                    ),
                    selected: orchestrator.selectedLevel == null,
                    selectedColor: AppColors.achievement.withAlpha(28),
                    side: BorderSide(color: AppColors.achievement),
                    onSelected: (_) => orchestrator.setLevel(null),
                  ),
                  for (final level in MobilityLevel.values)
                    ChoiceChip(
                      label: AppDirectionalText(
                        level.label,
                        languageCode: 'de',
                        style: AppTypography.label,
                      ),
                      selected: orchestrator.selectedLevel == level,
                      selectedColor: AppColors.achievement.withAlpha(28),
                      side: BorderSide(color: AppColors.achievement),
                      onSelected: (_) => orchestrator.setLevel(level),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _PlatformPanicCard extends StatelessWidget {
  const _PlatformPanicCard({required this.orchestrator});

  final MobilityMasterOrchestrator orchestrator;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.tertiary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppDirectionalText(
              'Gleiswechsel-Panikleiste',
              languageCode: 'de',
              style: AppTypography.title.copyWith(color: AppColors.tertiary),
            ),
            const SizedBox(height: 6),
            AppDirectionalText(
              'إذا تغيّر الرصيف فجأة، افتح الدليل السريع واتبع الخطوات بالترتيب.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: orchestrator.togglePanicBar,
              icon: Icon(
                orchestrator.isPanicBarOpen
                    ? Icons.expand_less_rounded
                    : Icons.train_rounded,
              ),
              label: AppDirectionalText(
                orchestrator.isPanicBarOpen
                    ? 'Schnellhilfe schließen'
                    : 'Gleiswechsel: Schnellhilfe öffnen',
                languageCode: 'de',
                style: AppTypography.label,
              ),
            ),
            if (orchestrator.isPanicBarOpen) ...[
              const SizedBox(height: 12),
              for (final step in orchestrator.platformPanicSteps) ...[
                AppDirectionalText(
                  step.titleDe,
                  languageCode: 'de',
                  style: AppTypography.label.copyWith(
                    color: AppColors.tertiary,
                  ),
                ),
                const SizedBox(height: 4),
                AppDirectionalText(
                  step.instructionAr,
                  languageCode: 'ar',
                  style: AppTypography.body,
                ),
                const SizedBox(height: 10),
              ],
            ],
          ],
        ),
      );
}

class _AgentOverviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.mastery,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppDirectionalText(
              'Zwei spezialisierte Sub-Agents',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: 10),
            _AgentLine(
              icon: Icons.train_rounded,
              titleDe: 'Deutsche Bahn & Fernverkehr',
              bodyAr: 'Gleiswechsel، التأخير، وحجز المقاعد.',
            ),
            const SizedBox(height: 10),
            _AgentLine(
              icon: Icons.directions_bus_rounded,
              titleDe: 'ÖPNV: Bus & U-Bahn',
              bodyAr: 'التذاكر المحلية، Deutschlandticket، ووصلات النقل المحلي.',
            ),
          ],
        ),
      );
}

class _AgentLine extends StatelessWidget {
  const _AgentLine({
    required this.icon,
    required this.titleDe,
    required this.bodyAr,
  });

  final IconData icon;
  final String titleDe;
  final String bodyAr;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.mastery),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppDirectionalText(
                  titleDe,
                  languageCode: 'de',
                  style: AppTypography.label,
                ),
                const SizedBox(height: 3),
                AppDirectionalText(
                  bodyAr,
                  languageCode: 'ar',
                  style: AppTypography.body,
                ),
              ],
            ),
          ),
        ],
      );
}

class _MobilityLessonCard extends StatelessWidget {
  const _MobilityLessonCard({required this.item});

  final MobilityLesson item;

  @override
  Widget build(BuildContext context) {
    final accent = item.mode == MobilityMode.longDistance
        ? AppColors.primary
        : AppColors.secondary;

    return AppGlassCard(
      glowColor: accent,
      borderColor: accent.withAlpha(72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _Tag(text: item.level.label, accent: accent),
                _Tag(text: item.topic.labelDe, accent: accent),
              ],
            ),
          ),
          const SizedBox(height: 10),
          AppDirectionalText(
            item.titleDe,
            languageCode: 'de',
            style: AppTypography.title,
          ),
          const SizedBox(height: 8),
          AppDirectionalText(
            item.phraseDe,
            languageCode: 'de',
            style: AppTypography.body.copyWith(color: accent),
          ),
          const SizedBox(height: 8),
          AppDirectionalText(
            item.meaningAr,
            languageCode: 'ar',
            style: AppTypography.body,
          ),
          const SizedBox(height: 8),
          AppDirectionalText(
            item.actionAr,
            languageCode: 'ar',
            style: AppTypography.label,
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.accent});

  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: accent.withAlpha(18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withAlpha(76)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          child: AppDirectionalText(
            text,
            languageCode: 'de',
            style: AppTypography.label.copyWith(color: accent),
          ),
        ),
      );
}

class _EmptyResultCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.tertiary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppDirectionalText(
              'Keine Treffer',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: 6),
            AppDirectionalText(
              'لا توجد نتيجة بهذا البحث ضمن المستوى المحدد. جرّب كلمة أقصر أو اختر كل المستويات.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}
