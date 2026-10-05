import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/design_system.dart';
import 'childcare_master_hub.dart';
import 'enrollment_attendance_agent.dart';
import 'parent_meetings_agent.dart';

abstract final class _ChildcareUi {
  static const double inset = 16;
  static const double gap = 14;
  static const double smallGap = 8;
  static const double radius = 18;
  static const int borderAlpha = 72;
  static const int selectedAlpha = 32;
}

final class ChildcareKindergartenMasterScreen extends StatefulWidget {
  const ChildcareKindergartenMasterScreen({super.key});

  @override
  State<ChildcareKindergartenMasterScreen> createState() =>
      _ChildcareKindergartenMasterScreenState();
}

final class _ChildcareKindergartenMasterScreenState
    extends State<ChildcareKindergartenMasterScreen> {
  late final ChildcareMasterHub _hub;
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _hub = ChildcareMasterHub(
      entries: <ChildcarePhrase>[
        ...EnrollmentAttendanceAgent.entries,
        ...ParentMeetingsAgent.entries,
      ],
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Color _surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurface
          : AppColors.lightSurface;

  @override
  Widget build(BuildContext context) {
    final surface = _surface(context);
    final entries = _hub.visibleEntries;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(_ChildcareUi.inset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AppGlassCard(
                key: const ValueKey<String>('childcare-header'),
                backgroundColor: surface,
                glowColor: AppColors.primary,
                borderColor:
                    AppColors.primary.withAlpha(_ChildcareUi.borderAlpha),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AppDirectionalText(
                      'الروضة والمدرسة',
                      languageCode: 'ar',
                      style: AppTypography.title,
                    ),
                    const SizedBox(height: _ChildcareUi.smallGap),
                    AppDirectionalText(
                      'Kita · Kindergarten · Schule',
                      languageCode: 'de',
                      style: AppTypography.display.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: _ChildcareUi.smallGap),
                    AppDirectionalText(
                      'تدريب عملي للتسجيل، الحضور والغياب، تفويض الاستلام، واجتماعات وتواصل أولياء الأمور.',
                      languageCode: 'ar',
                      style: AppTypography.body,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: _ChildcareUi.gap),
              _StatusCard(
                surface: surface,
                hub: _hub,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: _ChildcareUi.gap),
              _CategoryCard(
                surface: surface,
                hub: _hub,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: _ChildcareUi.gap),
              AppGlassCard(
                backgroundColor: surface,
                borderColor:
                    AppColors.secondary.withAlpha(_ChildcareUi.borderAlpha),
                child: TextField(
                  key: const ValueKey<String>('childcare-search'),
                  controller: _search,
                  textDirection: RegExp(r'[ء-ي]').hasMatch(_search.text)
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  style: AppTypography.body,
                  onChanged: (value) {
                    setState(() => _hub.setQuery(value));
                  },
                  decoration: InputDecoration(
                    hintText: 'Anmeldung · Abwesenheit · Elternabend · غياب',
                    hintStyle: AppTypography.body,
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.secondary),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(_ChildcareUi.radius),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: _ChildcareUi.gap),
              AppDirectionalText(
                'العبارات العملية',
                languageCode: 'ar',
                style: AppTypography.title,
              ),
              const SizedBox(height: _ChildcareUi.smallGap),
              if (entries.isEmpty)
                AppGlassCard(
                  key: const ValueKey<String>('childcare-empty'),
                  backgroundColor: surface,
                  child: AppDirectionalText(
                    'لا توجد نتائج. عدّل البحث أو الأقسام المحددة.',
                    languageCode: 'ar',
                    style: AppTypography.body,
                  ),
                )
              else
                for (var i = 0; i < entries.length; i++) ...<Widget>[
                  _PhraseCard(entry: entries[i], surface: surface),
                  if (i != entries.length - 1)
                    const SizedBox(height: _ChildcareUi.smallGap),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

final class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.surface,
    required this.hub,
    required this.onChanged,
  });

  final Color surface;
  final ChildcareMasterHub hub;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        key: const ValueKey<String>('childcare-status-card'),
        backgroundColor: surface,
        glowColor: AppColors.tertiary,
        borderColor: AppColors.tertiary.withAlpha(_ChildcareUi.borderAlpha),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'الموقف الحالي',
              languageCode: 'ar',
              style: AppTypography.title,
            ),
            const SizedBox(height: _ChildcareUi.smallGap),
            Wrap(
              spacing: _ChildcareUi.smallGap,
              runSpacing: _ChildcareUi.smallGap,
              children: <Widget>[
                for (final status in ChildcareStatus.values)
                  ChoiceChip(
                    key: ValueKey<String>('childcare-status-${status.name}'),
                    selected: hub.status == status,
                    selectedColor:
                        AppColors.tertiary.withAlpha(_ChildcareUi.selectedAlpha),
                    label: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        AppDirectionalText(
                          status.labelAr,
                          languageCode: 'ar',
                          style: AppTypography.label,
                        ),
                        AppDirectionalText(
                          status.labelDe,
                          languageCode: 'de',
                          style: AppTypography.label,
                        ),
                      ],
                    ),
                    onSelected: (_) {
                      hub.setStatus(status);
                      onChanged();
                    },
                  ),
              ],
            ),
            const SizedBox(height: _ChildcareUi.smallGap),
            AppDirectionalText(
              hub.statusPromptDe,
              languageCode: 'de',
              style: AppTypography.label.copyWith(color: AppColors.tertiary),
            ),
            AppDirectionalText(
              hub.statusPromptAr,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.surface,
    required this.hub,
    required this.onChanged,
  });

  final Color surface;
  final ChildcareMasterHub hub;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: AppColors.primary.withAlpha(_ChildcareUi.borderAlpha),
        child: Wrap(
          spacing: _ChildcareUi.smallGap,
          runSpacing: _ChildcareUi.smallGap,
          children: <Widget>[
            for (final category in ChildcareCategory.values)
              FilterChip(
                key: ValueKey<String>('childcare-category-${category.name}'),
                selected: hub.selected.contains(category),
                selectedColor:
                    AppColors.primary.withAlpha(_ChildcareUi.selectedAlpha),
                label: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AppDirectionalText(
                      category.labelAr,
                      languageCode: 'ar',
                      style: AppTypography.label,
                    ),
                    AppDirectionalText(
                      category.labelDe,
                      languageCode: 'de',
                      style: AppTypography.label,
                    ),
                  ],
                ),
                onSelected: (_) {
                  hub.toggleCategory(category);
                  onChanged();
                },
              ),
          ],
        ),
      );
}

final class _PhraseCard extends StatelessWidget {
  const _PhraseCard({required this.entry, required this.surface});

  final ChildcarePhrase entry;
  final Color surface;

  Color get _accent => switch (entry.category) {
        ChildcareCategory.enrollmentAttendance => AppColors.primary,
        ChildcareCategory.parentCommunication => AppColors.secondary,
      };

  @override
  Widget build(BuildContext context) => AppGlassCard(
        key: ValueKey<String>('childcare-entry-${entry.id}'),
        backgroundColor: surface,
        borderColor: _accent.withAlpha(_ChildcareUi.borderAlpha),
        glowColor: _accent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              entry.topicAr,
              languageCode: 'ar',
              style: AppTypography.label.copyWith(color: _accent),
            ),
            AppDirectionalText(
              entry.topicDe,
              languageCode: 'de',
              style: AppTypography.label,
            ),
            const SizedBox(height: _ChildcareUi.smallGap),
            AppDirectionalText(
              entry.german,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: _ChildcareUi.smallGap),
            AppDirectionalText(
              entry.arabic,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}
