import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/design_system.dart';
import 'furniture_home_models.dart';
import 'furniture_home_module.dart';

final class FurnitureHomeMasterScreen extends StatefulWidget {
  const FurnitureHomeMasterScreen({
    this.module = const FurnitureHomeSetupModule(),
    super.key,
  });

  final FurnitureHomeSetupModule module;

  @override
  State<FurnitureHomeMasterScreen> createState() =>
      _FurnitureHomeMasterScreenState();
}

final class _FurnitureHomeMasterScreenState
    extends State<FurnitureHomeMasterScreen> {
  late final FurnitureHomeSetupController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.module.createController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            dark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          title: const Text('الأثاث والمنزل · Möbel & Einrichtung'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppGlassCard(
                    glowColor: AppColors.primary,
                    borderColor: AppColors.primary.withAlpha(88),
                    backgroundColor: surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        AppDirectionalText(
                          'Möbel & Einrichtung',
                          languageCode: 'de',
                          style: AppTypography.title,
                        ),
                        const SizedBox(height: 8),
                        AppDirectionalText(
                          'مركز عملي لشراء الأثاث، التوصيل، الضمان، وتجهيز المنزل.',
                          languageCode: 'ar',
                          style: AppTypography.body,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    key: const ValueKey<String>('furniture-home-search'),
                    onChanged: _controller.setQuery,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: 'Suche · بحث',
                      hintText: 'Maße, Lieferung, Garantie ...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  AppGlassCard(
                    borderColor: AppColors.secondary.withAlpha(88),
                    backgroundColor: surface,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        for (final section in FurnitureHomeSection.values)
                          FilterChip(
                            key: ValueKey<String>(
                              'furniture-home-section-${section.name}',
                            ),
                            selected: _controller.section == section,
                            onSelected: (_) => _controller.setSection(section),
                            label: Text(_label(section)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  AppGlassCard(
                    borderColor: AppColors.tertiary.withAlpha(88),
                    backgroundColor: surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        AppDirectionalText(
                          _headline(_controller.section),
                          languageCode: 'de',
                          style: AppTypography.title,
                        ),
                        const SizedBox(height: 8),
                        AppDirectionalText(
                          _description(_controller.section),
                          languageCode: 'ar',
                          style: AppTypography.body,
                        ),
                        if (_controller.query.trim().isNotEmpty) ...<Widget>[
                          const SizedBox(height: 10),
                          AppDirectionalText(
                            'بحث نشط: ${_controller.query.trim()}',
                            languageCode: 'ar',
                            style: AppTypography.label,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _label(FurnitureHomeSection section) => switch (section) {
        FurnitureHomeSection.shopping => 'Kauf · شراء',
        FurnitureHomeSection.delivery => 'Lieferung · توصيل',
        FurnitureHomeSection.warranty => 'Garantie · ضمان',
      };

  static String _headline(FurnitureHomeSection section) => switch (section) {
        FurnitureHomeSection.shopping => 'Möbel auswählen und Maße prüfen',
        FurnitureHomeSection.delivery => 'Lieferung und Transport planen',
        FurnitureHomeSection.warranty =>
          'Garantie und Reklamation vorbereiten',
      };

  static String _description(FurnitureHomeSection section) => switch (section) {
        FurnitureHomeSection.shopping =>
          'ثبّت المقاسات والكمية وحالة الطلب قبل الشراء.',
        FurnitureHomeSection.delivery =>
          'حدّد مستوى التوصيل والعنوان والوقت المناسب بوضوح.',
        FurnitureHomeSection.warranty =>
          'احتفظ ببيانات الطلب ووصف الضرر وإثبات الشراء قبل المطالبة بالضمان.',
      };
}
