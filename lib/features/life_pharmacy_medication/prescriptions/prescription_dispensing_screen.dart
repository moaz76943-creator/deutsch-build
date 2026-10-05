import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../design_system/design_system.dart';
import 'prescription_dispensing_controller.dart';
import 'prescription_models.dart';

final class PrescriptionDispensingScreen extends StatefulWidget {
  const PrescriptionDispensingScreen({
    this.controller,
    super.key,
  });

  final PrescriptionDispensingController? controller;

  @override
  State<PrescriptionDispensingScreen> createState() =>
      _PrescriptionDispensingScreenState();
}

final class _PrescriptionDispensingScreenState
    extends State<PrescriptionDispensingScreen> {
  late final PrescriptionDispensingController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ?? PrescriptionDispensingController();
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor:
            dark ? AppColors.darkBackground : AppColors.lightBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _Header(dark: dark),
                  const SizedBox(height: 16),
                  _DistinctionCard(dark: dark),
                  const SizedBox(height: 16),
                  TextField(
                    key: const ValueKey<String>(
                      'prescription-search',
                    ),
                    onChanged: _controller.setQuery,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: 'Suche · بحث',
                      hintText:
                          'E-Rezept, Zuzahlung, Befreiung, Generikum ...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ChannelSelector(
                    controller: _controller,
                    dark: dark,
                  ),
                  const SizedBox(height: 16),
                  _PhraseList(
                    controller: _controller,
                    dark: dark,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _Header extends StatelessWidget {
  const _Header({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.primary,
        borderColor: AppColors.primary.withAlpha(96),
        backgroundColor:
            dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Rezept & Arzneimittelabgabe',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: 8),
            AppDirectionalText(
              'تدريب عملي على صرف الوصفات والرسوم والإعفاء والسؤال عن البدائل المسموح بها.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _DistinctionCard extends StatelessWidget {
  const _DistinctionCard({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.tertiary,
        borderColor: AppColors.tertiary.withAlpha(96),
        backgroundColor:
            dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Wichtig: E-Rezept, Privatrezept und Grünes Rezept sind nicht dasselbe.',
              languageCode: 'de',
              style: AppTypography.label,
            ),
            const SizedBox(height: 8),
            AppDirectionalText(
              'مهم: الوصفة الإلكترونية والوصفة الخاصة والوصفة الخضراء ليست نوعاً واحداً. الوصفة الخضراء تُستخدم كتوصية ولا تعني تلقائياً وصفة خاصة.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _ChannelSelector extends StatelessWidget {
  const _ChannelSelector({
    required this.controller,
    required this.dark,
  });

  final PrescriptionDispensingController controller;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.secondary.withAlpha(96),
        backgroundColor:
            dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final channel in PrescriptionChannel.values)
              FilterChip(
                key: ValueKey<String>(
                  'prescription-channel-${channel.name}',
                ),
                selected: controller.channel == channel,
                onSelected: (_) => controller.setChannel(channel),
                label: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AppDirectionalText(
                      channel.labelDe,
                      languageCode: 'de',
                      style: AppTypography.label,
                    ),
                    AppDirectionalText(
                      channel.labelAr,
                      languageCode: 'ar',
                      style: AppTypography.label,
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
}

final class _PhraseList extends StatelessWidget {
  const _PhraseList({
    required this.controller,
    required this.dark,
  });

  final PrescriptionDispensingController controller;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final phrases = controller.visiblePhrases;
    if (phrases.isEmpty) {
      return AppGlassCard(
        backgroundColor:
            dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: AppDirectionalText(
          'لا توجد نتائج في هذا النوع من الوصفات.',
          languageCode: 'ar',
          style: AppTypography.body,
        ),
      );
    }

    return Column(
      children: <Widget>[
        for (var index = 0;
            index < phrases.length;
            index++) ...<Widget>[
          AppGlassCard(
            borderColor: AppColors.primary.withAlpha(80),
            backgroundColor:
                dark ? AppColors.darkSurface : AppColors.lightSurface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppDirectionalText(
                  phrases[index].contextDe,
                  languageCode: 'de',
                  style: AppTypography.label,
                ),
                const SizedBox(height: 8),
                AppDirectionalText(
                  phrases[index].german,
                  languageCode: 'de',
                  style: AppTypography.title,
                ),
                const SizedBox(height: 8),
                AppDirectionalText(
                  phrases[index].arabic,
                  languageCode: 'ar',
                  style: AppTypography.body,
                ),
                const SizedBox(height: 8),
                AppDirectionalText(
                  phrases[index].contextAr,
                  languageCode: 'ar',
                  style: AppTypography.label,
                ),
              ],
            ),
          ),
          if (index != phrases.length - 1)
            const SizedBox(height: 12),
        ],
      ],
    );
  }
}
