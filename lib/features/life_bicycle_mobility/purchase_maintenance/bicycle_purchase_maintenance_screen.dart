import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart' hide AppDirectionalText;
import 'bicycle_purchase_maintenance_agent.dart';
import 'bicycle_purchase_maintenance_models.dart';

abstract final class _Ui {
  static const double inset = 16;
  static const double gap = 14;
  static const double small = 8;
}

class BicyclePurchaseMaintenanceHub extends StatefulWidget {
  const BicyclePurchaseMaintenanceHub({this.agent, super.key});

  final BicyclePurchaseMaintenanceAgent? agent;

  @override
  State<BicyclePurchaseMaintenanceHub> createState() =>
      _BicyclePurchaseMaintenanceHubState();
}

class _BicyclePurchaseMaintenanceHubState
    extends State<BicyclePurchaseMaintenanceHub> {
  late final BicyclePurchaseMaintenanceAgent _agent;
  late final bool _owns;
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _owns = widget.agent == null;
    _agent = widget.agent ?? BicyclePurchaseMaintenanceAgent();
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
              'Fahrradkauf & Werkstatt',
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
                          'Kaufen, einstellen, reparieren',
                          languageCode: 'de',
                          style: AppTypography.title,
                        ),
                        AppDirectionalText(
                          'شراء الدراجة وضبطها وإصلاحها بعبارات عملية كاملة.',
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
                        for (final topic in BicycleShopTopic.values)
                          ChoiceChip(
                            key: ValueKey<String>(
                              'bicycle-shop-topic-' + topic.name,
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
                      key: const ValueKey<String>('bicycle-shop-search'),
                      controller: _search,
                      onChanged: _agent.setQuery,
                      textDirection: TextDirection.rtl,
                      style: AppTypography.body,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search_rounded),
                        hintText: 'Reifen, Bremse / إطار، فرامل',
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
