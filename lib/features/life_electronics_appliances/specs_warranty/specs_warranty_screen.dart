import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart' hide AppDirectionalText;
import 'specs_warranty_agent.dart';
import 'specs_warranty_models.dart';

abstract final class _Ui {
  static const double inset = 16;
  static const double gap = 14;
  static const double small = 8;
}

class SpecsWarrantyHub extends StatefulWidget {
  const SpecsWarrantyHub({this.agent, super.key});

  final SpecsWarrantyAgent? agent;

  @override
  State<SpecsWarrantyHub> createState() => _SpecsWarrantyHubState();
}

class _SpecsWarrantyHubState extends State<SpecsWarrantyHub> {
  late final SpecsWarrantyAgent _agent;
  late final bool _owns;
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _owns = widget.agent == null;
    _agent = widget.agent ?? SpecsWarrantyAgent();
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
              'Geräteberatung & Garantie',
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
                          'Technik verstehen, Rechte sauber trennen',
                          languageCode: 'de',
                          style: AppTypography.title,
                        ),
                        AppDirectionalText(
                          'أسئلة مكتملة عن المواصفات والمقارنة والكفالة والإرجاع.',
                          languageCode: 'ar',
                          style: AppTypography.body,
                        ),
                        const SizedBox(height: _Ui.small),
                        AppDirectionalText(
                          _agent.guidanceDe,
                          languageCode: 'de',
                          style: AppTypography.label,
                        ),
                        AppDirectionalText(
                          _agent.guidanceAr,
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
                        for (final topic in SpecsWarrantyTopic.values)
                          ChoiceChip(
                            key: ValueKey<String>(
                              'specs-warranty-topic-' + topic.name,
                            ),
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
                      key: const ValueKey<String>('specs-warranty-search'),
                      controller: _search,
                      onChanged: _agent.setQuery,
                      textDirection: TextDirection.rtl,
                      style: AppTypography.body,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search_rounded),
                        hintText: 'Garantie, RAM / كفالة، ذاكرة',
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
