import 'package:flutter/foundation.dart';

import 'donation_and_social_sub_agent.dart';
import 'flea_market_and_ads_sub_agent.dart';
import 'secondhand_models.dart';

final class SecondhandMasterOrchestrator extends ChangeNotifier {
  SecondhandMasterOrchestrator({
    FleaMarketAndAdsSubAgent fleaMarketAndAds =
        const FleaMarketAndAdsSubAgent(),
    DonationAndSocialSubAgent donationAndSocial =
        const DonationAndSocialSubAgent(),
  })  : _fleaMarketAndAds = fleaMarketAndAds,
        _donationAndSocial = donationAndSocial;

  final FleaMarketAndAdsSubAgent _fleaMarketAndAds;
  final DonationAndSocialSubAgent _donationAndSocial;

  SecondhandDomain _domain = SecondhandDomain.fleaMarketsAndAds;
  String _query = '';

  SecondhandDomain get domain => _domain;
  String get query => _query;

  List<SecondhandBargainingTip> get bargainingTips =>
      const <SecondhandBargainingTip>[
        SecondhandBargainingTip(
          german:
              'VB bedeutet Verhandlungsbasis: freundlich fragen, nicht fordern.',
          arabic:
              'VB تعني أن السعر قابل للتفاوض: اسأل بلطف بدل فرض سعر جديد.',
        ),
        SecondhandBargainingTip(
          german:
              'Erst den Zustand prüfen, dann einen fairen konkreten Vorschlag machen: „Wie wäre es mit 25 Euro?“',
          arabic:
              'افحص حالة السلعة أولًا، ثم قدّم عرضًا واضحًا ومنصفًا: «ما رأيك في 25 يورو؟»',
        ),
        SecondhandBargainingTip(
          german:
              'Bei Abholung Preis, Zeitpunkt und Zahlungsart vorher bestätigen.',
          arabic:
              'عند الاستلام أكّد السعر والموعد وطريقة الدفع مسبقًا.',
        ),
      ];

  List<SecondhandEntry> get visibleEntries {
    final source = switch (_domain) {
      SecondhandDomain.fleaMarketsAndAds => _fleaMarketAndAds.entries,
      SecondhandDomain.donationAndSocialStores => _donationAndSocial.entries,
    };

    return List<SecondhandEntry>.unmodifiable(
      source.where((entry) => entry.matches(_query)),
    );
  }

  void setDomain(SecondhandDomain value) {
    if (_domain == value) return;
    _domain = value;
    notifyListeners();
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void clearSearch() => setQuery('');
}
