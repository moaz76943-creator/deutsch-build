import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart' hide AppDirectionalText;
import 'documents_models.dart';
import 'forms_documents_agent.dart';

abstract final class _DocumentsUi {
  static const double inset = 16;
  static const double sectionGap = 14;
  static const double itemGap = 10;
  static const double controlGap = 8;
}

class FormsDocumentsHub extends StatefulWidget {
  const FormsDocumentsHub({
    this.agent,
    super.key,
  });

  final FormsDocumentsAgent? agent;

  @override
  State<FormsDocumentsHub> createState() => _FormsDocumentsHubState();
}

class _FormsDocumentsHubState extends State<FormsDocumentsHub> {
  late final FormsDocumentsAgent _agent;
  late final bool _ownsAgent;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _ownsAgent = widget.agent == null;
    _agent = widget.agent ?? FormsDocumentsAgent();
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
              'Formulare & Dokumente',
              languageCode: 'de',
              style: AppTypography.title,
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(_DocumentsUi.inset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _NoticeCard(agent: _agent),
                  const SizedBox(height: _DocumentsUi.sectionGap),
                  _TopicFilter(agent: _agent),
                  const SizedBox(height: _DocumentsUi.sectionGap),
                  _SearchCard(
                    agent: _agent,
                    controller: _searchController,
                  ),
                  const SizedBox(height: _DocumentsUi.sectionGap),
                  if (phrases.isEmpty)
                    const _EmptyState()
                  else
                    for (final phrase in phrases) ...<Widget>[
                      _PhraseCard(phrase: phrase),
                      const SizedBox(height: _DocumentsUi.itemGap),
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

  final FormsDocumentsAgent agent;

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
            'Anträge und Nachweise vorbereiten',
            languageCode: 'de',
            style: AppTypography.title.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: _DocumentsUi.controlGap),
          AppDirectionalText(
            'تدريب عملي على الاستمارات وإثبات الهوية والتصديق والوكالات واستكمال الأوراق الناقصة.',
            languageCode: 'ar',
            style: AppTypography.body,
          ),
          const SizedBox(height: _DocumentsUi.controlGap),
          AppDirectionalText(
            agent.officialNoteDe,
            languageCode: 'de',
            style: AppTypography.label,
          ),
          const SizedBox(height: _DocumentsUi.controlGap),
          AppDirectionalText(
            agent.officialNoteAr,
            languageCode: 'ar',
            style: AppTypography.label,
          ),
        ],
      ),
    );
  }
}

final class _TopicFilter extends StatelessWidget {
  const _TopicFilter({required this.agent});

  final FormsDocumentsAgent agent;

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
            'Dokumentthema wählen',
            languageCode: 'de',
            style: AppTypography.title,
          ),
          const SizedBox(height: _DocumentsUi.controlGap),
          Wrap(
            spacing: _DocumentsUi.controlGap,
            runSpacing: _DocumentsUi.controlGap,
            children: <Widget>[
              for (final topic in DocumentsTopic.values)
                ChoiceChip(
                  key: ValueKey<String>('documents-topic-' + topic.name),
                  selected: agent.topic == topic,
                  onSelected: (_) => agent.setTopic(topic),
                  label: Column(
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

  final FormsDocumentsAgent agent;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return AppGlassCard(
      borderColor: AppColors.primary.withAlpha(64),
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: TextField(
        key: const ValueKey<String>('documents-search'),
        controller: controller,
        onChanged: agent.setQuery,
        textDirection: TextDirection.rtl,
        style: AppTypography.body,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search_rounded),
          label: AppDirectionalText(
            'ابحث في الاستمارات والمستندات',
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

  final DocumentsPhrase phrase;

  Color get _accent => switch (phrase.topic) {
        DocumentsTopic.formFilling => AppColors.primary,
        DocumentsTopic.identityProof => AppColors.secondary,
        DocumentsTopic.certification => AppColors.tertiary,
        DocumentsTopic.powerOfAttorney => AppColors.primary,
        DocumentsTopic.missingDocuments => AppColors.tertiary,
        DocumentsTopic.all => AppColors.secondary,
      };

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return AppGlassCard(
      borderColor: _accent.withAlpha(70),
      glowColor: _accent,
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            phrase.topic.labelDe,
            languageCode: 'de',
            style: AppTypography.label.copyWith(color: _accent),
          ),
          const SizedBox(height: _DocumentsUi.controlGap),
          AppDirectionalText(
            phrase.german,
            languageCode: 'de',
            style: AppTypography.body,
          ),
          const SizedBox(height: _DocumentsUi.controlGap),
          AppDirectionalText(
            phrase.arabic,
            languageCode: 'ar',
            style: AppTypography.body,
          ),
          const SizedBox(height: _DocumentsUi.controlGap),
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
        'لا توجد عبارات مطابقة. غيّر الموضوع أو عبارة البحث.',
        languageCode: 'ar',
        style: AppTypography.body,
        textAlign: TextAlign.center,
      ),
    );
  }
}
