import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../design_system/design_system.dart';
import '../application/family_education_master_orchestrator.dart';
import '../domain/education_models.dart';

abstract final class _EducationUiTokens {
  static const double pageInset = 16;
  static const double sectionGap = 14;
  static const double contentGap = 10;
  static const double compactGap = 8;
  static const double bottomInset = 32;
  static const double iconSize = 20;
}

final class FamilyEducationMasterScreen extends StatefulWidget {
  FamilyEducationMasterScreen({
    FamilyEducationMasterOrchestrator? orchestrator,
    super.key,
  }) : orchestrator =
            orchestrator ?? FamilyEducationMasterOrchestrator.standard();

  final FamilyEducationMasterOrchestrator orchestrator;

  @override
  State<FamilyEducationMasterScreen> createState() =>
      _FamilyEducationMasterScreenState();
}

final class _FamilyEducationMasterScreenState
    extends State<FamilyEducationMasterScreen> {
  EducationLevel? _selectedLevel;
  EducationArea? _selectedArea;
  EducationArea _absenceArea = EducationArea.school;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final results = widget.orchestrator.filter(
      level: _selectedLevel,
      area: _selectedArea,
      query: _query,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          title: AppDirectionalText(
            'Kita & Schule',
            languageCode: 'de',
            style: AppTypography.title,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              _EducationUiTokens.pageInset,
              _EducationUiTokens.pageInset,
              _EducationUiTokens.pageInset,
              _EducationUiTokens.bottomInset,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _EmergencyAbsenceBar(
                  message:
                      widget.orchestrator.emergencyAbsence(_absenceArea),
                  selectedArea: _absenceArea,
                  onAreaChanged: (area) {
                    setState(() => _absenceArea = area);
                  },
                ),
                const SizedBox(height: _EducationUiTokens.sectionGap),
                _FilterPanel(
                  selectedLevel: _selectedLevel,
                  selectedArea: _selectedArea,
                  onLevelChanged: (level) {
                    setState(() => _selectedLevel = level);
                  },
                  onAreaChanged: (area) {
                    setState(() => _selectedArea = area);
                  },
                  onQueryChanged: (query) {
                    setState(() => _query = query);
                  },
                ),
                const SizedBox(height: _EducationUiTokens.sectionGap),
                _ResultsHeader(count: results.length),
                const SizedBox(height: _EducationUiTokens.contentGap),
                if (results.isEmpty)
                  const _EmptyState()
                else
                  for (var index = 0; index < results.length; index++) ...[
                    _EducationEntryCard(entry: results[index]),
                    if (index != results.length - 1)
                      const SizedBox(height: _EducationUiTokens.sectionGap),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _EmergencyAbsenceBar extends StatelessWidget {
  const _EmergencyAbsenceBar({
    required this.message,
    required this.selectedArea,
    required this.onAreaChanged,
  });

  final EmergencyAbsenceMessage message;
  final EducationArea selectedArea;
  final ValueChanged<EducationArea> onAreaChanged;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.tertiary,
        glowColor: AppColors.tertiary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(
                  Icons.notification_important_outlined,
                  color: AppColors.tertiary,
                  size: _EducationUiTokens.iconSize,
                ),
                const SizedBox(width: _EducationUiTokens.compactGap),
                Expanded(
                  child: AppDirectionalText(
                    'شريط الغياب العاجل',
                    languageCode: 'ar',
                    style: AppTypography.title,
                  ),
                ),
              ],
            ),
            const SizedBox(height: _EducationUiTokens.contentGap),
            Wrap(
              spacing: _EducationUiTokens.compactGap,
              runSpacing: _EducationUiTokens.compactGap,
              children: EducationArea.values
                  .map(
                    (area) => ChoiceChip(
                      label: Text(
                        _areaLabelAr(area),
                        style: AppTypography.label,
                      ),
                      selected: selectedArea == area,
                      selectedColor: AppColors.tertiary,
                      onSelected: (_) => onAreaChanged(area),
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: _EducationUiTokens.contentGap),
            AppDirectionalText(
              message.titleDe,
              languageCode: 'de',
              style: AppTypography.label.copyWith(color: AppColors.tertiary),
            ),
            const SizedBox(height: _EducationUiTokens.compactGap),
            AppDirectionalText(
              message.germanText,
              languageCode: 'de',
              style: AppTypography.body,
            ),
            const SizedBox(height: _EducationUiTokens.compactGap),
            AppDirectionalText(
              message.arabicGuidance,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _FilterPanel extends StatelessWidget {
  const _FilterPanel({
    required this.selectedLevel,
    required this.selectedArea,
    required this.onLevelChanged,
    required this.onAreaChanged,
    required this.onQueryChanged,
  });

  final EducationLevel? selectedLevel;
  final EducationArea? selectedArea;
  final ValueChanged<EducationLevel?> onLevelChanged;
  final ValueChanged<EducationArea?> onAreaChanged;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.primary,
        glowColor: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'بحث وتصفية المحتوى',
              languageCode: 'ar',
              style: AppTypography.title,
            ),
            const SizedBox(height: _EducationUiTokens.contentGap),
            TextField(
              textDirection: TextDirection.rtl,
              style: AppTypography.body,
              textInputAction: TextInputAction.search,
              onChanged: onQueryChanged,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.primary,
                ),
                label: Text(
                  'ابحث: Hausaufgaben، حساسية، Elternabend...',
                  style: AppTypography.body,
                ),
              ),
            ),
            const SizedBox(height: _EducationUiTokens.contentGap),
            AppDirectionalText(
              'المستوى',
              languageCode: 'ar',
              style: AppTypography.label,
            ),
            const SizedBox(height: _EducationUiTokens.compactGap),
            Wrap(
              spacing: _EducationUiTokens.compactGap,
              runSpacing: _EducationUiTokens.compactGap,
              children: <Widget>[
                FilterChip(
                  label: Text('الكل', style: AppTypography.label),
                  selected: selectedLevel == null,
                  selectedColor: AppColors.primary,
                  onSelected: (_) => onLevelChanged(null),
                ),
                for (final level in EducationLevel.values)
                  FilterChip(
                    label: Text(level.label, style: AppTypography.label),
                    selected: selectedLevel == level,
                    selectedColor: AppColors.primary,
                    onSelected: (_) => onLevelChanged(level),
                  ),
              ],
            ),
            const SizedBox(height: _EducationUiTokens.contentGap),
            AppDirectionalText(
              'القسم',
              languageCode: 'ar',
              style: AppTypography.label,
            ),
            const SizedBox(height: _EducationUiTokens.compactGap),
            Wrap(
              spacing: _EducationUiTokens.compactGap,
              runSpacing: _EducationUiTokens.compactGap,
              children: <Widget>[
                FilterChip(
                  label: Text('الكل', style: AppTypography.label),
                  selected: selectedArea == null,
                  selectedColor: AppColors.secondary,
                  onSelected: (_) => onAreaChanged(null),
                ),
                for (final area in EducationArea.values)
                  FilterChip(
                    label: Text(
                      _areaLabelAr(area),
                      style: AppTypography.label,
                    ),
                    selected: selectedArea == area,
                    selectedColor: AppColors.secondary,
                    onSelected: (_) => onAreaChanged(area),
                  ),
              ],
            ),
          ],
        ),
      );
}

final class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          const Icon(
            Icons.school_outlined,
            color: AppColors.secondary,
            size: _EducationUiTokens.iconSize,
          ),
          const SizedBox(width: _EducationUiTokens.compactGap),
          Expanded(
            child: AppDirectionalText(
              'النتائج: ' + count.toString(),
              languageCode: 'ar',
              style: AppTypography.label,
            ),
          ),
        ],
      );
}

final class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.tertiary,
        child: AppDirectionalText(
          'لا توجد نتائج مطابقة. غيّر المستوى أو القسم أو كلمة البحث.',
          languageCode: 'ar',
          style: AppTypography.body,
        ),
      );
}

final class _EducationEntryCard extends StatelessWidget {
  const _EducationEntryCard({required this.entry});

  final EducationEntry entry;

  @override
  Widget build(BuildContext context) {
    final accent = _areaColor(entry.area);

    return AppGlassCard(
      borderColor: accent,
      glowColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Wrap(
            spacing: _EducationUiTokens.compactGap,
            runSpacing: _EducationUiTokens.compactGap,
            children: <Widget>[
              _MetaChip(label: entry.level.label, accent: accent),
              _MetaChip(label: _areaLabelAr(entry.area), accent: accent),
              _MetaChip(label: _topicLabelAr(entry.topic), accent: accent),
            ],
          ),
          const SizedBox(height: _EducationUiTokens.contentGap),
          AppDirectionalText(
            entry.titleDe,
            languageCode: 'de',
            style: AppTypography.title,
          ),
          const SizedBox(height: _EducationUiTokens.compactGap),
          AppDirectionalText(
            entry.titleAr,
            languageCode: 'ar',
            style: AppTypography.label.copyWith(color: accent),
          ),
          const SizedBox(height: _EducationUiTokens.contentGap),
          AppDirectionalText(
            entry.germanText,
            languageCode: 'de',
            style: AppTypography.body,
          ),
          const SizedBox(height: _EducationUiTokens.compactGap),
          AppDirectionalText(
            entry.arabicText,
            languageCode: 'ar',
            style: AppTypography.body,
          ),
          if (entry.noteAr.isNotEmpty) ...<Widget>[
            const SizedBox(height: _EducationUiTokens.compactGap),
            AppDirectionalText(
              entry.noteAr,
              languageCode: 'ar',
              style: AppTypography.label.copyWith(color: AppColors.tertiary),
            ),
          ],
        ],
      ),
    );
  }
}

final class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.label,
    required this.accent,
  });

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: accent),
          borderRadius: BorderRadius.circular(_EducationUiTokens.contentGap),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _EducationUiTokens.contentGap,
            vertical: _EducationUiTokens.compactGap,
          ),
          child: Text(
            label,
            style: AppTypography.label.copyWith(color: accent),
          ),
        ),
      );
}

Color _areaColor(EducationArea area) => switch (area) {
      EducationArea.daycare => AppColors.secondary,
      EducationArea.school => AppColors.primary,
    };

String _areaLabelAr(EducationArea area) => switch (area) {
      EducationArea.daycare => 'الحضانة / Kita',
      EducationArea.school => 'المدرسة / Schule',
    };

String _topicLabelAr(EducationTopic topic) => switch (topic) {
      EducationTopic.dropOffPickup => 'توصيل واستلام',
      EducationTopic.allergy => 'حساسية',
      EducationTopic.dailyRoutine => 'روتين يومي',
      EducationTopic.careTimes => 'أوقات الرعاية',
      EducationTopic.sickLeave => 'غياب مرضي',
      EducationTopic.parentTeacherConference => 'اجتماع ولي الأمر',
      EducationTopic.homework => 'واجبات',
    };
