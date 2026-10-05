import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/app_colors.dart';
import '../../design_system/app_glass_card.dart';
import '../../design_system/app_typography.dart' hide AppDirectionalText;
import 'clothing_master_orchestrator.dart';
import 'fitting/fitting_panel.dart';
import 'tailoring/tailoring_panel.dart';

class ClothingAlterationsMasterScreen extends StatefulWidget {
  const ClothingAlterationsMasterScreen({
    this.orchestrator = const ClothingMasterOrchestrator(),
    super.key,
  });

  final ClothingMasterOrchestrator orchestrator;

  @override
  State<ClothingAlterationsMasterScreen> createState() =>
      _ClothingAlterationsMasterScreenState();
}

class _ClothingAlterationsMasterScreenState
    extends State<ClothingAlterationsMasterScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('الملابس والخياطة'),
            bottom: const TabBar(
              tabs: <Tab>[
                Tab(text: 'المركز'),
                Tab(text: 'القياس'),
                Tab(text: 'الخياطة'),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              _overview(context),
              ClothingFittingPanel(
                agent: widget.orchestrator.dependencies.fittingAgent,
              ),
              ClothingTailoringPanel(
                agent: widget.orchestrator.dependencies.tailoringAgent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _overview(BuildContext context) {
    final matches = widget.orchestrator.search(_query);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppGlassCard(
            glowColor: AppColors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Clothing & Änderungsschneiderei',
                  textDirection: TextDirection.ltr,
                  style: AppTypography.title,
                ),
                const SizedBox(height: 6),
                Text(
                  'مركز عملي للملابس اليومية الكلاسيكية، القياس، والخياطة.',
                  style: AppTypography.body,
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (value) => setState(() => _query = value),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    labelText: 'ابحث في عبارات القياس والخياطة',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (_query.trim().isNotEmpty)
            AppGlassCard(
              glowColor: AppColors.achievement,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('نتائج البحث', style: AppTypography.title),
                  const SizedBox(height: 8),
                  if (matches.isEmpty)
                    Text('لا توجد نتيجة مطابقة.', style: AppTypography.body),
                  for (final item in matches) ...[
                    Text(
                      item.german,
                      textDirection: TextDirection.ltr,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(item.arabic, style: AppTypography.body),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 14),
          AppGlassCard(
            glowColor: AppColors.secondary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الخامات الطبيعية', style: AppTypography.title),
                const SizedBox(height: 8),
                for (final info in ClothingMasterOrchestrator.fabricGuide) ...[
                  Text(
                    info.fabric.arabic + ' · ' + info.fabric.german,
                    style: AppTypography.label.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                  Text(
                    info.descriptionDe,
                    textDirection: TextDirection.ltr,
                    style: AppTypography.body,
                  ),
                  Text(info.descriptionAr, style: AppTypography.body),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppGlassCard(
            glowColor: AppColors.achievement,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('مراجع المقاسات', style: AppTypography.title),
                const SizedBox(height: 8),
                for (final size in ClothingMasterOrchestrator.sizeGuide) ...[
                  Text(
                    size.garment.arabic +
                        ' · ' +
                        size.garment.german +
                        ' · ' +
                        size.label +
                        ' · EU ' +
                        size.euReference,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(size.noteAr, style: AppTypography.body),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
