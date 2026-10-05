import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/design_system.dart';
import 'supermarket_master_orchestrator.dart';
import 'supermarket_models.dart';

abstract final class SupermarketUiTokens {
  static const double pageInset = 16;
  static const double bottomInset = 32;
  static const double sectionGap = 18;
  static const double itemGap = 12;
  static const double compactGap = 8;
  static const int softBorderAlpha = 88;
  static const int subtleBorderAlpha = 56;
}

final class SupermarketGroceriesMasterHub extends StatefulWidget {
  const SupermarketGroceriesMasterHub({
    this.module = const SupermarketGroceriesModule(),
    super.key,
  });

  final SupermarketGroceriesModule module;

  @override
  State<SupermarketGroceriesMasterHub> createState() =>
      _SupermarketGroceriesMasterHubState();
}

final class _SupermarketGroceriesMasterHubState
    extends State<SupermarketGroceriesMasterHub> {
  late final SupermarketMasterOrchestrator _orchestrator;

  @override
  void initState() {
    super.initState();
    _orchestrator = widget.module.createOrchestrator();
  }

  @override
  void dispose() {
    _orchestrator.dispose();
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
              SupermarketUiTokens.pageInset,
              SupermarketUiTokens.pageInset,
              SupermarketUiTokens.pageInset,
              SupermarketUiTokens.bottomInset,
            ),
            child: AnimatedBuilder(
              animation: _orchestrator,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _HeaderCard(dark: dark),
                  const SizedBox(height: SupermarketUiTokens.sectionGap),
                  _SearchField(orchestrator: _orchestrator),
                  const SizedBox(height: SupermarketUiTokens.sectionGap),
                  _ModuleRoutesCard(
                    routes: widget.module.routes,
                    dark: dark,
                  ),
                  const SizedBox(height: SupermarketUiTokens.sectionGap),
                  _ProductsCard(
                    products: _orchestrator.visibleProducts,
                    dark: dark,
                  ),
                  const SizedBox(height: SupermarketUiTokens.sectionGap),
                  _OffersCard(
                    offers: _orchestrator.visibleOffers,
                    dark: dark,
                  ),
                  const SizedBox(height: SupermarketUiTokens.sectionGap),
                  _ReceiptPreview(
                    receipt: _orchestrator.receipt,
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
        borderColor:
            AppColors.primary.withAlpha(SupermarketUiTokens.softBorderAlpha),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _GermanText(
              'Supermarkt & Lebensmittel',
              title: true,
            ),
            SizedBox(height: SupermarketUiTokens.compactGap),
            _ArabicText(
              'مركز عملي للتسوق في ألمانيا: المنتجات والمكونات والعروض والصندوق وإيصالات الدفع.',
            ),
          ],
        ),
      );
}

final class _SearchField extends StatelessWidget {
  const _SearchField({required this.orchestrator});

  final SupermarketMasterOrchestrator orchestrator;

  @override
  Widget build(BuildContext context) => TextField(
        key: const ValueKey<String>('supermarket-master-search'),
        onChanged: orchestrator.setQuery,
        textDirection: TextDirection.ltr,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          labelText: 'Produkt oder Angebot · منتج أو عرض',
          hintText: 'Haferflocken, Milch, Angebot ...',
          border: OutlineInputBorder(),
        ),
      );
}

final class _ModuleRoutesCard extends StatelessWidget {
  const _ModuleRoutesCard({
    required this.routes,
    required this.dark,
  });

  final List<SupermarketModuleRoute> routes;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor:
            AppColors.secondary.withAlpha(SupermarketUiTokens.softBorderAlpha),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const _GermanText('Bereiche', title: true),
            const SizedBox(height: SupermarketUiTokens.itemGap),
            for (final route in routes) ...<Widget>[
              Row(
                children: <Widget>[
                  const Icon(Icons.chevron_right),
                  const SizedBox(width: SupermarketUiTokens.compactGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _GermanText(route.labelDe, emphasized: true),
                        _ArabicText(route.labelAr),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SupermarketUiTokens.itemGap),
            ],
          ],
        ),
      );
}

final class _ProductsCard extends StatelessWidget {
  const _ProductsCard({
    required this.products,
    required this.dark,
  });

  final List<GroceryProduct> products;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor:
            AppColors.primary.withAlpha(SupermarketUiTokens.subtleBorderAlpha),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const _GermanText('Produkte & Zutaten', title: true),
            const SizedBox(height: SupermarketUiTokens.itemGap),
            if (products.isEmpty)
              const _ArabicText('لا توجد منتجات مطابقة للبحث.')
            else
              for (final product in products) ...<Widget>[
                _GermanText(product.nameDe, emphasized: true),
                _ArabicText(product.nameAr),
                const SizedBox(height: SupermarketUiTokens.compactGap),
                _GermanText('Regal: ${product.aisleDe}'),
                _ArabicText('المكان: ${product.aisleAr}'),
                if (product.dietaryFlags.isNotEmpty) ...<Widget>[
                  const SizedBox(height: SupermarketUiTokens.compactGap),
                  _GermanText(
                    product.dietaryFlags
                        .map((flag) => flag.labelDe)
                        .join(' · '),
                  ),
                ],
                const Divider(),
              ],
          ],
        ),
      );
}

final class _OffersCard extends StatelessWidget {
  const _OffersCard({
    required this.offers,
    required this.dark,
  });

  final List<GroceryOffer> offers;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.secondary,
        borderColor:
            AppColors.secondary.withAlpha(SupermarketUiTokens.subtleBorderAlpha),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const _GermanText('Angebote', title: true),
            const SizedBox(height: SupermarketUiTokens.itemGap),
            if (offers.isEmpty)
              const _ArabicText('لا توجد عروض مطابقة للبحث.')
            else
              for (final offer in offers) ...<Widget>[
                _GermanText(offer.labelDe, emphasized: true),
                _ArabicText(offer.labelAr),
                _GermanText(
                  '${offer.priceEuro.toStringAsFixed(2)} € · ${offer.unitLabel}',
                ),
                const SizedBox(height: SupermarketUiTokens.itemGap),
              ],
          ],
        ),
      );
}

final class _ReceiptPreview extends StatelessWidget {
  const _ReceiptPreview({
    required this.receipt,
    required this.dark,
  });

  final Kassenbon receipt;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor:
            AppColors.tertiary.withAlpha(SupermarketUiTokens.softBorderAlpha),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const _GermanText('Kassenbon', title: true),
            const _ArabicText('مثال تعليمي على إيصال الدفع'),
            const SizedBox(height: SupermarketUiTokens.itemGap),
            for (final line in receipt.lines)
              _GermanText(
                '${line.quantity} × ${line.label} = ${line.total.toStringAsFixed(2)} €',
              ),
            const Divider(),
            _GermanText(
              'Summe: ${receipt.total.toStringAsFixed(2)} €',
              emphasized: true,
            ),
          ],
        ),
      );
}

final class _GermanText extends StatelessWidget {
  const _GermanText(
    this.text, {
    this.title = false,
    this.emphasized = false,
  });

  final String text;
  final bool title;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.ltr,
        child: AppDirectionalText(
          text,
          languageCode: 'de',
          style: title
              ? AppTypography.title
              : emphasized
                  ? AppTypography.label
                  : AppTypography.body,
        ),
      );
}

final class _ArabicText extends StatelessWidget {
  const _ArabicText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AppDirectionalText(
          text,
          languageCode: 'ar',
          style: AppTypography.body,
        ),
      );
}
