import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../design_system/design_system.dart';
import '../application/doctor_appointment_master_orchestrator.dart';
import '../domain/doctor_appointment_models.dart';

abstract final class _DoctorHubTokens {
  static const double pageInset = 16;
  static const double gap = 12;
  static const double sectionGap = 16;
  static const double bottomInset = 36;
}

final class DoctorAppointmentMasterHub extends StatefulWidget {
  const DoctorAppointmentMasterHub({
    required this.orchestrator,
    super.key,
  });

  final DoctorAppointmentMasterOrchestrator orchestrator;

  @override
  State<DoctorAppointmentMasterHub> createState() =>
      _DoctorAppointmentMasterHubState();
}

final class _DoctorAppointmentMasterHubState
    extends State<DoctorAppointmentMasterHub> {
  DoctorClinicType? _clinicType;
  String _query = '';

  List<DoctorHubPhrase> get _visiblePhrases =>
      widget.orchestrator.search(
        _query,
        clinicType: _clinicType,
      );

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final background =
        dark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;
    final border =
        dark ? AppColors.glassBorderDark : AppColors.glassBorderLight;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          title: const AppDirectionalText(
            'زيارة عيادة الطبيب',
            languageCode: 'ar',
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              _DoctorHubTokens.pageInset,
              _DoctorHubTokens.pageInset,
              _DoctorHubTokens.pageInset,
              _DoctorHubTokens.bottomInset,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _HeaderCard(surface: surface, border: border),
                const SizedBox(height: _DoctorHubTokens.sectionGap),
                _ClinicSelector(
                  selected: _clinicType,
                  surface: surface,
                  border: border,
                  onSelected: (value) =>
                      setState(() => _clinicType = value),
                  onClear: () => setState(() => _clinicType = null),
                ),
                const SizedBox(height: _DoctorHubTokens.sectionGap),
                _DocumentSection(
                  documents: widget.orchestrator.documents,
                  selectedClinic: _clinicType,
                  surface: surface,
                  border: border,
                ),
                const SizedBox(height: _DoctorHubTokens.sectionGap),
                _ChecklistSection(
                  items: widget.orchestrator.appointmentChecklist,
                  surface: surface,
                  border: border,
                ),
                const SizedBox(height: _DoctorHubTokens.sectionGap),
                _SearchSection(
                  items: _visiblePhrases,
                  surface: surface,
                  border: border,
                  onChanged: (value) => setState(() => _query = value),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.surface,
    required this.border,
  });

  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        glowColor: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Arztbesuch & Termin',
              languageCode: 'de',
              style: AppTypography.title.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: _DoctorHubTokens.gap),
            AppDirectionalText(
              'مركز لغوي لمراجعة الزيارة اليومية للعيادة: طبيب الأسرة والطبيب المختص والمستندات الأساسية.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(height: _DoctorHubTokens.gap),
            AppDirectionalText(
              'Sprachtraining – keine medizinische Beratung.',
              languageCode: 'de',
              style: AppTypography.label.copyWith(
                color: AppColors.tertiary,
              ),
            ),
          ],
        ),
      );
}

final class _ClinicSelector extends StatelessWidget {
  const _ClinicSelector({
    required this.selected,
    required this.surface,
    required this.border,
    required this.onSelected,
    required this.onClear,
  });

  final DoctorClinicType? selected;
  final Color surface;
  final Color border;
  final ValueChanged<DoctorClinicType> onSelected;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Praxis auswählen · اختر نوع العيادة',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: _DoctorHubTokens.gap),
            Wrap(
              spacing: _DoctorHubTokens.gap,
              runSpacing: _DoctorHubTokens.gap,
              children: <Widget>[
                ChoiceChip(
                  label: const AppDirectionalText(
                    'Alle',
                    languageCode: 'de',
                  ),
                  selected: selected == null,
                  onSelected: (_) => onClear(),
                ),
                for (final type in DoctorClinicType.values)
                  ChoiceChip(
                    label: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        AppDirectionalText(
                          type.german,
                          languageCode: 'de',
                          style: AppTypography.label,
                        ),
                        AppDirectionalText(
                          type.arabic,
                          languageCode: 'ar',
                          style: AppTypography.label,
                        ),
                      ],
                    ),
                    selected: selected == type,
                    onSelected: (_) => onSelected(type),
                  ),
              ],
            ),
          ],
        ),
      );
}

final class _DocumentSection extends StatelessWidget {
  const _DocumentSection({
    required this.documents,
    required this.selectedClinic,
    required this.surface,
    required this.border,
  });

  final List<DoctorDocumentCard> documents;
  final DoctorClinicType? selectedClinic;
  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) {
    final visible = documents
        .where(
          (item) =>
              selectedClinic == null ||
              item.clinicType == null ||
              item.clinicType == selectedClinic,
        )
        .toList(growable: false);

    return AppGlassCard(
      backgroundColor: surface,
      borderColor: border,
      glowColor: AppColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            'Gesundheitskarte & Überweisung',
            languageCode: 'de',
            style: AppTypography.title.copyWith(
              color: AppColors.secondary,
            ),
          ),
          for (final document in visible) ...<Widget>[
            const SizedBox(height: _DoctorHubTokens.gap),
            AppDirectionalText(
              document.titleDe,
              languageCode: 'de',
              style: AppTypography.label,
            ),
            AppDirectionalText(
              document.titleAr,
              languageCode: 'ar',
              style: AppTypography.label,
            ),
            AppDirectionalText(
              document.promptDe,
              languageCode: 'de',
              style: AppTypography.body,
            ),
            AppDirectionalText(
              document.explanationAr,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ],
      ),
    );
  }
}

final class _ChecklistSection extends StatelessWidget {
  const _ChecklistSection({
    required this.items,
    required this.surface,
    required this.border,
  });

  final List<DoctorAppointmentChecklistItem> items;
  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Termin-Check',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            for (final item in items) ...<Widget>[
              const SizedBox(height: _DoctorHubTokens.gap),
              AppDirectionalText(
                item.titleDe,
                languageCode: 'de',
                style: AppTypography.label,
              ),
              AppDirectionalText(
                item.titleAr,
                languageCode: 'ar',
                style: AppTypography.label,
              ),
              AppDirectionalText(
                item.detailDe,
                languageCode: 'de',
                style: AppTypography.body,
              ),
              AppDirectionalText(
                item.detailAr,
                languageCode: 'ar',
                style: AppTypography.body,
              ),
            ],
          ],
        ),
      );
}

final class _SearchSection extends StatelessWidget {
  const _SearchSection({
    required this.items,
    required this.surface,
    required this.border,
    required this.onChanged,
  });

  final List<DoctorHubPhrase> items;
  final Color surface;
  final Color border;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        glowColor: AppColors.achievement,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Directionality(
              textDirection: TextDirection.ltr,
              child: TextField(
                onChanged: onChanged,
                style: AppTypography.body,
                decoration: const InputDecoration(
                  hintText: 'Termin / Gesundheitskarte / إحالة',
                ),
              ),
            ),
            const SizedBox(height: _DoctorHubTokens.gap),
            for (final item in items) ...<Widget>[
              AppDirectionalText(
                item.german,
                languageCode: 'de',
                style: AppTypography.body,
              ),
              AppDirectionalText(
                item.arabic,
                languageCode: 'ar',
                style: AppTypography.body,
              ),
              const SizedBox(height: _DoctorHubTokens.gap),
            ],
          ],
        ),
      );
}
