import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/app_colors.dart';
import '../../design_system/app_glass_card.dart';
import '../../design_system/app_typography.dart' hide AppDirectionalText;

final class MaintenanceMasterHub extends StatelessWidget {
  const MaintenanceMasterHub({
    required this.onOpenRepairs,
    required this.onOpenWasteSorting,
    super.key,
  });

  final VoidCallback onOpenRepairs;
  final VoidCallback onOpenWasteSorting;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;
    final background =
        dark ? AppColors.darkBackground : AppColors.lightBackground;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          title: const Text('صيانة المنزل وإدارة النفايات'),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: <Widget>[
              AppGlassCard(
                backgroundColor: surface,
                glowColor: AppColors.primary,
                borderColor: AppColors.primary.withAlpha(88),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Hauswartung & Entsorgung',
                      textDirection: TextDirection.ltr,
                      style: AppTypography.display.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'المهمة الخمسون تجمع مسارين موجودين بالفعل: طلب فني للصيانة المنزلية، وفرز النفايات والتخلص منها. لا تكرر المحتوى بل توجهك إلى المحرك المتخصص المناسب.',
                      style: AppTypography.body,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _UrgentBreakdownBar(
                surface: surface,
                onOpenRepairs: onOpenRepairs,
              ),
              const SizedBox(height: 14),
              _MaintenanceEntryCard(
                key: const ValueKey<String>('maintenance-repairs'),
                icon: Icons.home_repair_service_outlined,
                titleAr: 'إصلاحات المنزل',
                titleDe: 'Handwerker & Reparaturen',
                descriptionAr:
                    'أعطال التدفئة، الأقفال، التسربات، تقدير التكلفة، وحماية المستهلك قبل بدء العمل.',
                actionLabel: 'فتح مسار الصيانة',
                accent: AppColors.primary,
                surface: surface,
                onPressed: onOpenRepairs,
              ),
              const SizedBox(height: 14),
              _MaintenanceEntryCard(
                key: const ValueKey<String>('maintenance-waste'),
                icon: Icons.recycling_outlined,
                titleAr: 'فرز النفايات والتدوير',
                titleDe: 'Mülltrennung & Recycling',
                descriptionAr:
                    'Gelber Sack وBiomüll وRestmüll وSperrmüll وPfand، مع توجيه محلي عندما تختلف القواعد.',
                actionLabel: 'فتح مسار الفرز',
                accent: AppColors.secondary,
                surface: surface,
                onPressed: onOpenWasteSorting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _UrgentBreakdownBar extends StatelessWidget {
  const _UrgentBreakdownBar({
    required this.surface,
    required this.onOpenRepairs,
  });

  final Color surface;
  final VoidCallback onOpenRepairs;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        glowColor: AppColors.tertiary,
        borderColor: AppColors.tertiary.withAlpha(96),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.tertiary,
              size: 30,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'عطل منزلي عاجل؟',
                    style: AppTypography.title,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bei Wasserschaden, Heizungsausfall oder ausgesperrter Tür: Situation sichern, Kosten vor Auftrag klären und den passenden Fachbetrieb öffnen.',
                    textDirection: TextDirection.ltr,
                    style: AppTypography.body,
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: onOpenRepairs,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('الانتقال إلى المساعدة'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

final class _MaintenanceEntryCard extends StatelessWidget {
  const _MaintenanceEntryCard({
    required this.icon,
    required this.titleAr,
    required this.titleDe,
    required this.descriptionAr,
    required this.actionLabel,
    required this.accent,
    required this.surface,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String titleAr;
  final String titleDe;
  final String descriptionAr;
  final String actionLabel;
  final Color accent;
  final Color surface;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        glowColor: accent,
        borderColor: accent.withAlpha(82),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, color: accent, size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(titleAr, style: AppTypography.title),
                      Text(
                        titleDe,
                        textDirection: TextDirection.ltr,
                        style: AppTypography.label.copyWith(color: accent),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(descriptionAr, style: AppTypography.body),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.open_in_new_rounded),
              label: Text(actionLabel),
            ),
          ],
        ),
      );
}
