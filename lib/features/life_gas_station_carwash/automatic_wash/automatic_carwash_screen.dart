import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart' hide AppDirectionalText;
import 'automatic_carwash_agent.dart';
import 'automatic_carwash_models.dart';

abstract final class _Ui {
  static const double inset = 16;
  static const double gap = 14;
  static const double small = 8;
}

class AutomaticCarwashHub extends StatefulWidget {
  const AutomaticCarwashHub({this.agent, super.key});

  final AutomaticCarwashAgent? agent;

  @override
  State<AutomaticCarwashHub> createState() => _AutomaticCarwashHubState();
}

class _AutomaticCarwashHubState extends State<AutomaticCarwashHub> {
  late final AutomaticCarwashAgent _agent;
  late final bool _owns;
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _owns = widget.agent == null;
    _agent = widget.agent ?? AutomaticCarwashAgent();
    _search = TextEditingController(text: _agent.query);
  }

  @override
  void dispose() {
    _search.dispose();
    if (_owns) _agent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _agent,
      builder: (context, _) {
        final dark = Theme.of(context).brightness == Brightness.dark;
        return Scaffold(
          appBar: AppBar(
            title: AppDirectionalText(
              'Automatische Autowäsche',
              languageCode: 'de',
              style: AppTypography.title,
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(_Ui.inset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppGlassCard(
                    glowColor: AppColors.primary,
                    borderColor: AppColors.primary.withAlpha(76),
                    backgroundColor:
                        dark ? AppColors.darkSurface : AppColors.lightSurface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        AppDirectionalText(
                          'Waschanlage Schritt für Schritt',
                          languageCode: 'de',
                          style: AppTypography.title,
                        ),
                        AppDirectionalText(
                          'اختيار البرنامج وتجهيز السيارة والدخول والخروج وفق تعليمات المغسلة.',
                          languageCode: 'ar',
                          style: AppTypography.body,
                        ),
                        const SizedBox(height: _Ui.small),
                        AppDirectionalText(
                          _agent.safetyNoteDe,
                          languageCode: 'de',
                          style: AppTypography.label,
                        ),
                        AppDirectionalText(
                          _agent.safetyNoteAr,
                          languageCode: 'ar',
                          style: AppTypography.label,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: _Ui.gap),
                  AppGlassCard(
                    borderColor: AppColors.secondary.withAlpha(72),
                    backgroundColor:
                        dark ? AppColors.darkSurface : AppColors.lightSurface,
                    child: Wrap(
                      spacing: _Ui.small,
                      runSpacing: _Ui.small,
                      children: <Widget>[
                        for (final topic in CarwashTopic.values)
                          ChoiceChip(
                            key: ValueKey<String>('carwash-topic-' + topic.name),
                            selected: _agent.topic == topic,
                            onSelected: (_) => _agent.setTopic(topic),
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
                  ),
                  const SizedBox(height: _Ui.gap),
                  AppGlassCard(
                    borderColor: AppColors.primary.withAlpha(64),
                    backgroundColor:
                        dark ? AppColors.darkSurface : AppColors.lightSurface,
                    child: TextField(
                      key: const ValueKey<String>('carwash-search'),
                      controller: _search,
                      onChanged: _agent.setQuery,
                      textDirection: TextDirection.rtl,
                      style: AppTypography.body,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search_rounded),
                        hintText: 'Waschcode, Spiegel / رمز، مرايا',
                      ),
                    ),
                  ),
                  const SizedBox(height: _Ui.gap),
                  for (final phrase in _agent.visiblePhrases) ...<Widget>[
                    AppGlassCard(
                      borderColor: AppColors.secondary.withAlpha(70),
                      backgroundColor:
                          dark ? AppColors.darkSurface : AppColors.lightSurface,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          AppDirectionalText(
                            phrase.topic.labelDe,
                            languageCode: 'de',
                            style: AppTypography.label.copyWith(
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(height: _Ui.small),
                          AppDirectionalText(
                            phrase.german,
                            languageCode: 'de',
                            style: AppTypography.body,
                          ),
                          AppDirectionalText(
                            phrase.arabic,
                            languageCode: 'ar',
                            style: AppTypography.body,
                          ),
                          const SizedBox(height: _Ui.small),
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
                    ),
                    const SizedBox(height: _Ui.small),
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
