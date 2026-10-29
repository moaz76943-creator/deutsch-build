import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/design_system.dart';
import 'postal_master_orchestrator.dart';
import 'postal_models.dart';

abstract final class PostalUiTokens {
  static const double pageInset = 16;
  static const double bottomInset = 32;
  static const double sectionGap = 18;
  static const double itemGap = 12;
  static const double compactGap = 8;
}

final class PostalDeliveryMasterHub extends StatefulWidget {
  const PostalDeliveryMasterHub({
    this.orchestrator,
    super.key,
  });

  final PostalDeliveryMasterOrchestrator? orchestrator;

  @override
  State<PostalDeliveryMasterHub> createState() =>
      _PostalDeliveryMasterHubState();
}

final class _PostalDeliveryMasterHubState
    extends State<PostalDeliveryMasterHub> {
  late final PostalDeliveryMasterOrchestrator _orchestrator;
  late final bool _ownsOrchestrator;

  @override
  void initState() {
    super.initState();
    _ownsOrchestrator = widget.orchestrator == null;
    _orchestrator =
        widget.orchestrator ?? PostalDeliveryMasterOrchestrator();
  }

  @override
  void dispose() {
    if (_ownsOrchestrator) _orchestrator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor:
            dark ? AppColors.darkBackground : AppColors.lightBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              PostalUiTokens.pageInset,
              PostalUiTokens.pageInset,
              PostalUiTokens.pageInset,
              PostalUiTokens.bottomInset,
            ),
            child: AnimatedBuilder(
              animation: _orchestrator,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _HeaderCard(dark: dark),
                  const SizedBox(height: PostalUiTokens.sectionGap),
                  _SearchField(orchestrator: _orchestrator),
                  const SizedBox(height: PostalUiTokens.itemGap),
                  _AreaSelector(
                    orchestrator: _orchestrator,
                    dark: dark,
                  ),
                  const SizedBox(height: PostalUiTokens.sectionGap),
                  _SharedPostalDataCard(dark: dark),
                  const SizedBox(height: PostalUiTokens.sectionGap),
                  _ActionList(
                    orchestrator: _orchestrator,
                    dark: dark,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.primary,
        borderColor: AppColors.primary.withAlpha(96),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Post, Pakete & Versand',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: PostalUiTokens.compactGap),
            AppDirectionalText(
              'البريد والطرود والشحن',
              languageCode: 'ar',
              style: AppTypography.title,
            ),
            const SizedBox(height: PostalUiTokens.compactGap),
            AppDirectionalText(
              'DHL · Hermes · Deutsche Post',
              languageCode: 'de',
              style: AppTypography.label,
            ),
          ],
        ),
      );
}

final class _SearchField extends StatelessWidget {
  const _SearchField({required this.orchestrator});

  final PostalDeliveryMasterOrchestrator orchestrator;

  @override
  Widget build(BuildContext context) => TextField(
        key: const ValueKey<String>('postal-master-search'),
        onChanged: orchestrator.setQuery,
        textDirection: TextDirection.ltr,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          labelText: 'Suche · بحث',
          hintText: 'Sendungsnummer, Paketmaße, Packstation ...',
          border: OutlineInputBorder(),
        ),
      );
}

final class _AreaSelector extends StatelessWidget {
  const _AreaSelector({
    required this.orchestrator,
    required this.dark,
  });

  final PostalDeliveryMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.secondary.withAlpha(96),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Wrap(
          spacing: PostalUiTokens.compactGap,
          runSpacing: PostalUiTokens.compactGap,
          children: <Widget>[
            for (final area in PostalServiceArea.values)
              FilterChip(
                key: ValueKey<String>('postal-area-${area.name}'),
                selected: orchestrator.area == area,
                onSelected: (_) => orchestrator.setArea(area),
                label: Text(
                  '${area.labelDe} · ${area.labelAr}',
                  style: AppTypography.label,
                ),
              ),
          ],
        ),
      );
}

final class _SharedPostalDataCard extends StatelessWidget {
  const _SharedPostalDataCard({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    const tracking = PostalTrackingNumber(
      carrier: PostalCarrier.dhl,
      value: 'JD 01 234 567 DE',
    );
    const size = ParcelDimensions(
      lengthCm: 40,
      widthCm: 30,
      heightCm: 15,
      weightKg: 2.5,
    );
    const notice = DeliveryNotificationCard(
      carrier: PostalCarrier.deutschePost,
      pickupLocation: 'Filiale / Paketshop',
      pickupDeadline: 'Abholfrist prüfen',
      referenceNumber: 'Benachrichtigungskarte',
    );

    return AppGlassCard(
      glowColor: AppColors.secondary,
      borderColor: AppColors.secondary.withAlpha(96),
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            'Schnellübersicht · Versanddaten',
            languageCode: 'de',
            style: AppTypography.title,
          ),
          const SizedBox(height: PostalUiTokens.itemGap),
          _DataRow(
            labelDe: 'Sendungsnummer',
            valueDe: '${tracking.carrier.labelDe}: ${tracking.value}',
            valueAr: 'رقم التتبع: احتفظ به كما هو مطبوع.',
          ),
          _DataRow(
            labelDe: 'Paketmaße',
            valueDe: '${size.dimensionLabelDe} · ${size.weightLabelDe}',
            valueAr: 'أبعاد الطرد ووزنه قبل اختيار المنتج البريدي.',
          ),
          _DataRow(
            labelDe: 'Benachrichtigungskarte',
            valueDe:
                '${notice.pickupLocation} · ${notice.pickupDeadline}',
            valueAr: 'بطاقة الإشعار تحدد مكان وموعد الاستلام.',
          ),
        ],
      ),
    );
  }
}

final class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.labelDe,
    required this.valueDe,
    required this.valueAr,
  });

  final String labelDe;
  final String valueDe;
  final String valueAr;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: PostalUiTokens.itemGap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              labelDe,
              languageCode: 'de',
              style: AppTypography.label,
            ),
            AppDirectionalText(
              valueDe,
              languageCode: 'de',
              style: AppTypography.body,
            ),
            AppDirectionalText(
              valueAr,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _ActionList extends StatelessWidget {
  const _ActionList({
    required this.orchestrator,
    required this.dark,
  });

  final PostalDeliveryMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final actions = orchestrator.visibleActions;
    if (actions.isEmpty) {
      return AppGlassCard(
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: AppDirectionalText(
          'لا توجد نتيجة مطابقة. جرّب عبارة أخرى.',
          languageCode: 'ar',
          style: AppTypography.body,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (var index = 0; index < actions.length; index++) ...<Widget>[
          _ActionCard(action: actions[index], dark: dark),
          if (index != actions.length - 1)
            const SizedBox(height: PostalUiTokens.itemGap),
        ],
      ],
    );
  }
}

final class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action, required this.dark});

  final PostalHubAction action;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.primary.withAlpha(80),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              action.titleDe,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: PostalUiTokens.compactGap),
            AppDirectionalText(
              action.titleAr,
              languageCode: 'ar',
              style: AppTypography.title,
            ),
            const SizedBox(height: PostalUiTokens.compactGap),
            AppDirectionalText(
              action.descriptionDe,
              languageCode: 'de',
              style: AppTypography.body,
            ),
            const SizedBox(height: PostalUiTokens.compactGap),
            AppDirectionalText(
              action.descriptionAr,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}
