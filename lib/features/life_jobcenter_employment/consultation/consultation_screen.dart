import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../design_system/design_system.dart';
import 'consultation_jobs_orchestrator.dart';
import 'consultation_models.dart';

abstract final class _ConsultationUiTokens {
  static const double pageInset = 16;
  static const double topInset = 18;
  static const double bottomInset = 32;
  static const double sectionGap = 14;
  static const double contentGap = 10;
  static const double smallGap = 7;
}

final class ConsultationJobsScreen extends StatefulWidget {
  const ConsultationJobsScreen({
    required this.orchestrator,
    super.key,
  });

  final ConsultationJobsOrchestrator orchestrator;

  @override
  State<ConsultationJobsScreen> createState() =>
      _ConsultationJobsScreenState();
}

final class _ConsultationJobsScreenState
    extends State<ConsultationJobsScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  ConsultationJobsOrchestrator get orchestrator =>
      widget.orchestrator;

  @override
  void initState() {
    super.initState();
    orchestrator.addListener(_refresh);
  }

  @override
  void didUpdateWidget(covariant ConsultationJobsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orchestrator == orchestrator) return;
    oldWidget.orchestrator.removeListener(_refresh);
    orchestrator.addListener(_refresh);
    _searchController.text = orchestrator.query;
  }

  @override
  void dispose() {
    orchestrator.removeListener(_refresh);
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _selectTopic(ConsultationTopic topic) {
    _searchController.clear();
    orchestrator.setTopic(topic);
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final surface =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark
        ? AppColors.glassBorderDark
        : AppColors.glassBorderLight;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              _ConsultationUiTokens.pageInset,
              _ConsultationUiTokens.topInset,
              _ConsultationUiTokens.pageInset,
              _ConsultationUiTokens.bottomInset,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _HeaderCard(surface: surface, border: border),
                const SizedBox(
                  height: _ConsultationUiTokens.sectionGap,
                ),
                _SafetyCard(surface: surface),
                const SizedBox(
                  height: _ConsultationUiTokens.sectionGap,
                ),
                _TopicSelector(
                  activeTopic: orchestrator.activeTopic,
                  surface: surface,
                  border: border,
                  onSelected: _selectTopic,
                ),
                const SizedBox(
                  height: _ConsultationUiTokens.sectionGap,
                ),
                _SearchCard(
                  controller: _searchController,
                  query: orchestrator.query,
                  surface: surface,
                  border: border,
                  onChanged: orchestrator.setQuery,
                  onClear: () {
                    _searchController.clear();
                    orchestrator.clearSearch();
                  },
                ),
                const SizedBox(
                  height: _ConsultationUiTokens.sectionGap,
                ),
                _PhraseList(
                  phrases: orchestrator.visiblePhrases,
                  surface: surface,
                  border: border,
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
              'Beratung, Jobsuche & Förderung',
              languageCode: 'de',
              style: AppTypography.title.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: _ConsultationUiTokens.smallGap),
            AppDirectionalText(
              'الاستشارة والبحث عن عمل والتمويل',
              languageCode: 'ar',
              style: AppTypography.title,
            ),
            const SizedBox(height: _ConsultationUiTokens.smallGap),
            AppDirectionalText(
              'عبارات للمقابلة مع Sachbearbeiter/in، وصف المهارات، تمويل الدورات، متابعة Bewerbungen وتكاليف السفر للمقابلات.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _SafetyCard extends StatelessWidget {
  const _SafetyCard({required this.surface});

  final Color surface;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: AppColors.tertiary,
        glowColor: AppColors.tertiary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Förderung vorher klären',
              languageCode: 'de',
              style: AppTypography.label.copyWith(
                color: AppColors.tertiary,
              ),
            ),
            const SizedBox(height: _ConsultationUiTokens.smallGap),
            AppDirectionalText(
              'لا تفترض أن الدورة أو تكاليف السفر ممولة تلقائياً. اسأل عن الإمكانية والشروط والموافقة المطلوبة قبل الالتزام بالتكلفة.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _TopicSelector extends StatelessWidget {
  const _TopicSelector({
    required this.activeTopic,
    required this.surface,
    required this.border,
    required this.onSelected,
  });

  final ConsultationTopic activeTopic;
  final Color surface;
  final Color border;
  final ValueChanged<ConsultationTopic> onSelected;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: _ConsultationUiTokens.contentGap,
        runSpacing: _ConsultationUiTokens.contentGap,
        children: <Widget>[
          for (final topic in ConsultationTopic.values)
            AppGlassCard(
              onTap: () => onSelected(topic),
              backgroundColor: surface,
              borderColor: topic == activeTopic
                  ? AppColors.secondary
                  : border,
              glowColor:
                  topic == activeTopic ? AppColors.secondary : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AppDirectionalText(
                    topic.labelDe,
                    languageCode: 'de',
                    style: AppTypography.label,
                  ),
                  AppDirectionalText(
                    topic.labelAr,
                    languageCode: 'ar',
                    style: AppTypography.label,
                  ),
                ],
              ),
            ),
        ],
      );
}

final class _SearchCard extends StatelessWidget {
  const _SearchCard({
    required this.controller,
    required this.query,
    required this.surface,
    required this.border,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final Color surface;
  final Color border;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              labelText: 'Suche · بحث',
              hintText:
                  'Sachbearbeiter, Sprachkurs, Bewerbungen ...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: onClear,
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
        ),
      );
}

final class _PhraseList extends StatelessWidget {
  const _PhraseList({
    required this.phrases,
    required this.surface,
    required this.border,
  });

  final List<ConsultationPhrase> phrases;
  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) {
    if (phrases.isEmpty) {
      return AppGlassCard(
        backgroundColor: surface,
        borderColor: AppColors.tertiary,
        child: AppDirectionalText(
          'لا توجد نتيجة مطابقة في هذا القسم.',
          languageCode: 'ar',
          style: AppTypography.body,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (var index = 0; index < phrases.length; index++) ...<Widget>[
          _PhraseCard(
            phrase: phrases[index],
            surface: surface,
            border: border,
          ),
          if (index != phrases.length - 1)
            const SizedBox(
              height: _ConsultationUiTokens.contentGap,
            ),
        ],
      ],
    );
  }
}

final class _PhraseCard extends StatelessWidget {
  const _PhraseCard({
    required this.phrase,
    required this.surface,
    required this.border,
  });

  final ConsultationPhrase phrase;
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
              phrase.contextDe,
              languageCode: 'de',
              style: AppTypography.label.copyWith(
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: _ConsultationUiTokens.smallGap),
            AppDirectionalText(
              phrase.german,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: _ConsultationUiTokens.smallGap),
            AppDirectionalText(
              phrase.arabic,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(height: _ConsultationUiTokens.smallGap),
            AppDirectionalText(
              phrase.contextAr,
              languageCode: 'ar',
              style: AppTypography.label,
            ),
          ],
        ),
      );
}
