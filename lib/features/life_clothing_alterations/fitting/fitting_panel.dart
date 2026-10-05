import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart' hide AppDirectionalText;
import 'fitting_agent.dart';
import 'fitting_models.dart';

class ClothingFittingPanel extends StatefulWidget {
  const ClothingFittingPanel({
    this.agent = const ClothingFittingAgent(),
    super.key,
  });

  final ClothingFittingAgent agent;

  @override
  State<ClothingFittingPanel> createState() => _ClothingFittingPanelState();
}

class _ClothingFittingPanelState extends State<ClothingFittingPanel> {
  FittingGarmentType? _garment;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final items = widget.agent.findDialogues(
      garment: _garment,
      query: _query,
    );
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppGlassCard(
              glowColor: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('تجربة الملابس والمقاسات', style: AppTypography.title),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (value) => setState(() => _query = value),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded),
                      labelText: 'ابحث في العبارات',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('الكل'),
                        selected: _garment == null,
                        onSelected: (_) => setState(() => _garment = null),
                      ),
                      for (final garment in FittingGarmentType.values)
                        ChoiceChip(
                          label: Text(garment.arabic + ' · ' + garment.german),
                          selected: _garment == garment,
                          onSelected: (_) =>
                              setState(() => _garment = garment),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            for (final dialogue in items) ...[
              AppGlassCard(
                glowColor: AppColors.secondary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dialogue.german,
                      textDirection: TextDirection.ltr,
                      style: AppTypography.title.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 6),
                    Text(dialogue.arabic, style: AppTypography.body),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}
