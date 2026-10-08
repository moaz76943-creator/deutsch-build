import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart' hide AppDirectionalText;
import 'anmeldung_appointments_agent.dart';
import 'anmeldung_models.dart';

abstract final class _AnmeldungUi {
  static const double inset = 16;
  static const double sectionGap = 14;
  static const double itemGap = 10;
  static const double controlGap = 8;
}

class AnmeldungAppointmentsHub extends StatefulWidget {
  const AnmeldungAppointmentsHub({
    this.agent,
    super.key,
  });

  final AnmeldungAppointmentsAgent? agent;

  @override
  State<AnmeldungAppointmentsHub> createState() =>
      _AnmeldungAppointmentsHubState();
}

class _AnmeldungAppointmentsHubState extends State<AnmeldungAppointmentsHub> {
  late final AnmeldungAppointmentsAgent _agent;
  late final bool _ownsAgent;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _ownsAgent = widget.agent == null;
    _agent = widget.agent ?? AnmeldungAppointmentsAgent();
    _searchController = TextEditingController(text: _agent.query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_ownsAgent) _agent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _agent,
      builder: (context, _) {
        final phrases = _agent.visiblePhrases;

        return Scaffold(
          appBar: AppBar(
            title: AppDirectionalText(
              'Anmeldung & Termine',
              languageCode: 'de',
              style: AppTypography.title,
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(_AnmeldungUi.inset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _NoticeCard(agent: _agent),
                  const SizedBox(height: _AnmeldungUi.sectionGap),
                  _RegistrationFilter(agent: _agent),
                  const SizedBox(height: _AnmeldungUi.sectionGap),
                  _AppointmentFilter(agent: _agent),
                  const SizedBox(height: _AnmeldungUi.sectionGap),
                  _SearchCard(
                    agent: _agent,
                    controller: _searchController,
                  ),
                  const SizedBox(height: _AnmeldungUi.sectionGap),
                  if (phrases.isEmpty)
                    const _EmptyState()
                  else
                    for (final phrase in phrases) ...<Widget>[
                      _PhraseCard(phrase: phrase),
                      const SizedBox(height: _AnmeldungUi.itemGap),
                    ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

final class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.agent});

  final AnmeldungAppointmentsAgent agent;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return AppGlassCard(
      glowColor: AppColors.primary,
      borderColor: AppColors.primary.withAlpha(78),
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            'Bürgeramt sicher vorbereiten',
            languageCode: 'de',
            style: AppTypography.title.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: _AnmeldungUi.controlGap),
          AppDirectionalText(
            'تدريب عملي على تسجيل السكن، تغيير العنوان، شهادة التسجيل، وحجز المواعيد.',
            languageCode: 'ar',
            style: AppTypography.body,
          ),
          const SizedBox(height: _AnmeldungUi.controlGap),
          AppDirectionalText(
            agent.preparationNoteDe,
            languageCode: 'de',
            style: AppTypography.label,
          ),
          const SizedBox(height: _AnmeldungUi.controlGap),
          AppDirectionalText(
            agent.preparationNoteAr,
            languageCode: 'ar',
            style: AppTypography.label,
          ),
        ],
      ),
    );
  }
}

final class _RegistrationFilter extends StatelessWidget {
  const _RegistrationFilter({required this.agent});

  final AnmeldungAppointmentsAgent agent;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return AppGlassCard(
      borderColor: AppColors.secondary.withAlpha(72),
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            'Meldeanliegen',
            languageCode: 'de',
            style: AppTypography.title,
          ),
          const SizedBox(height: _AnmeldungUi.controlGap),
          Wrap(
            spacing: _AnmeldungUi.controlGap,
            runSpacing: _AnmeldungUi.controlGap,
            children: <Widget>[
              for (final action in RegistrationAction.values)
                ChoiceChip(
                  key: ValueKey<String>(
                    'registration-action-' + action.name,
                  ),
                  selected: agent.registrationAction == action,
                  onSelected: (_) => agent.setRegistrationAction(action),
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AppDirectionalText(
                        action.labelDe,
                        languageCode: 'de',
                        style: AppTypography.label,
                      ),
                      AppDirectionalText(
                        action.labelAr,
                        languageCode: 'ar',
                        style: AppTypography.label,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

final class _AppointmentFilter extends StatelessWidget {
  const _AppointmentFilter({required this.agent});

  final AnmeldungAppointmentsAgent agent;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return AppGlassCard(
      borderColor: AppColors.tertiary.withAlpha(72),
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            'Terminvereinbarung',
            languageCode: 'de',
            style: AppTypography.title,
          ),
          const SizedBox(height: _AnmeldungUi.controlGap),
          Wrap(
            spacing: _AnmeldungUi.controlGap,
            runSpacing: _AnmeldungUi.controlGap,
            children: <Widget>[
              for (final action in AppointmentAction.values)
                ChoiceChip(
                  key: ValueKey<String>(
                    'appointment-action-' + action.name,
                  ),
                  selected: agent.appointmentAction == action,
                  onSelected: (_) => agent.setAppointmentAction(action),
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AppDirectionalText(
                        action.labelDe,
                        languageCode: 'de',
                        style: AppTypography.label,
                      ),
                      AppDirectionalText(
                        action.labelAr,
                        languageCode: 'ar',
                        style: AppTypography.label,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

final class _SearchCard extends StatelessWidget {
  const _SearchCard({
    required this.agent,
    required this.controller,
  });

  final AnmeldungAppointmentsAgent agent;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return AppGlassCard(
      borderColor: AppColors.primary.withAlpha(64),
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: TextField(
        key: const ValueKey<String>('anmeldung-search'),
        controller: controller,
        onChanged: agent.setQuery,
        textDirection: TextDirection.rtl,
        style: AppTypography.body,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search_rounded),
          label: AppDirectionalText(
            'ابحث في عبارات الشباك والمواعيد',
            languageCode: 'ar',
            style: AppTypography.label,
          ),
          suffixIcon: agent.query.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Suche löschen',
                  onPressed: () {
                    controller.clear();
                    agent.setQuery('');
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
        ),
      ),
    );
  }
}

final class _PhraseCard extends StatelessWidget {
  const _PhraseCard({required this.phrase});

  final AnmeldungPhrase phrase;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return AppGlassCard(
      borderColor: AppColors.secondary.withAlpha(70),
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Wrap(
            spacing: _AnmeldungUi.controlGap,
            runSpacing: _AnmeldungUi.controlGap,
            children: <Widget>[
              AppDirectionalText(
                phrase.registrationAction.labelDe,
                languageCode: 'de',
                style: AppTypography.label.copyWith(
                  color: AppColors.secondary,
                ),
              ),
              if (phrase.appointmentAction != null)
                AppDirectionalText(
                  phrase.appointmentAction!.labelDe,
                  languageCode: 'de',
                  style: AppTypography.label,
                ),
            ],
          ),
          const SizedBox(height: _AnmeldungUi.controlGap),
          AppDirectionalText(
            phrase.german,
            languageCode: 'de',
            style: AppTypography.body,
          ),
          const SizedBox(height: _AnmeldungUi.controlGap),
          AppDirectionalText(
            phrase.arabic,
            languageCode: 'ar',
            style: AppTypography.body,
          ),
          const SizedBox(height: _AnmeldungUi.controlGap),
          AppDirectionalText(
            phrase.contextDe,
            languageCode: 'de',
            style: AppTypography.label,
          ),
          AppDirectionalText(
            phrase.contextAr,
            languageCode: 'ar',
            style: AppTypography.label,
          ),
        ],
      ),
    );
  }
}

final class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return AppGlassCard(
      borderColor: AppColors.secondary.withAlpha(64),
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: AppDirectionalText(
        'لا توجد عبارات مطابقة. غيّر نوع المعاملة أو الموعد أو البحث.',
        languageCode: 'ar',
        style: AppTypography.body,
        textAlign: TextAlign.center,
      ),
    );
  }
}
