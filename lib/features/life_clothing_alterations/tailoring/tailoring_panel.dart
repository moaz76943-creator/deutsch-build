import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart' hide AppDirectionalText;
import 'tailoring_agent.dart';
import 'tailoring_models.dart';

class ClothingTailoringPanel extends StatefulWidget {
  const ClothingTailoringPanel({
    this.agent = const ClothingTailoringAgent(),
    super.key,
  });

  final ClothingTailoringAgent agent;

  @override
  State<ClothingTailoringPanel> createState() => _ClothingTailoringPanelState();
}

class _ClothingTailoringPanelState extends State<ClothingTailoringPanel> {
  TailoringService? _service;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final items = widget.agent.findDialogues(
      service: _service,
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
              glowColor: AppColors.achievement,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('الخياطة والتعديلات', style: AppTypography.title),
                  const SizedBox(height: 8),
                  Text(
                    'تقصير، تعديل أكمام، وتصليح السحّابات والجيوب والأزرار.',
                    style: AppTypography.body,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (value) => setState(() => _query = value),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded),
                      labelText: 'ابحث في خدمات التعديل',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<TailoringService?>(
                    initialValue: _service,
                    decoration: const InputDecoration(
                      labelText: 'نوع الخدمة',
                      border: OutlineInputBorder(),
                    ),
                    items: <DropdownMenuItem<TailoringService?>>[
                      const DropdownMenuItem<TailoringService?>(
                        value: null,
                        child: Text('كل الخدمات'),
                      ),
                      for (final service in TailoringService.values)
                        DropdownMenuItem<TailoringService?>(
                          value: service,
                          child: Text(service.arabic + ' · ' + service.german),
                        ),
                    ],
                    onChanged: (value) => setState(() => _service = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            for (final dialogue in items) ...[
              AppGlassCard(
                glowColor: AppColors.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dialogue.service.arabic + ' · ' + dialogue.service.german,
                      style: AppTypography.label.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dialogue.german,
                      textDirection: TextDirection.ltr,
                      style: AppTypography.title.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 4),
                    Text(dialogue.arabic, style: AppTypography.body),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            if (_service != null && widget.agent.agreementFor(_service!) != null)
              AppGlassCard(
                glowColor: AppColors.secondary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('موعد الجاهزية والتكلفة', style: AppTypography.title),
                    const SizedBox(height: 8),
                    Text(
                      widget.agent.agreementFor(_service!)!.readyWhenDe,
                      textDirection: TextDirection.ltr,
                      style: AppTypography.body,
                    ),
                    Text(
                      widget.agent.agreementFor(_service!)!.costQuestionDe,
                      textDirection: TextDirection.ltr,
                      style: AppTypography.body,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
