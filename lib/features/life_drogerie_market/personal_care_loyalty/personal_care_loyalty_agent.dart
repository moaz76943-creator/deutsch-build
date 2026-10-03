import '../drogerie_models.dart';

final class PersonalCareLoyaltyAgent {
  const PersonalCareLoyaltyAgent();

  List<DrogeriePhrase> get items => const <DrogeriePhrase>[
        DrogeriePhrase(
          id: 'pcl_shampoo',
          category: DrogerieCategory.personalCare,
          german: 'Ich suche ein mildes Shampoo für empfindliche Kopfhaut.',
          arabic: 'أبحث عن شامبو لطيف لفروة رأس حساسة.',
          tags: <String>['Shampoo', 'Kopfhaut', 'empfindlich', 'عناية'],
        ),
        DrogeriePhrase(
          id: 'pcl_deo',
          category: DrogerieCategory.personalCare,
          german: 'Wo finde ich Deodorant ohne Duftstoffe?',
          arabic: 'أين أجد مزيل عرق من دون عطور؟',
          tags: <String>['Deodorant', 'ohne Duftstoffe', 'عناية'],
        ),
        DrogeriePhrase(
          id: 'pcl_toothpaste',
          category: DrogerieCategory.personalCare,
          german: 'Welche Zahnpasta ist für empfindliche Zähne gekennzeichnet?',
          arabic: 'أي معجون أسنان مذكور عليه أنه للأسنان الحساسة؟',
          tags: <String>['Zahnpasta', 'empfindliche Zähne'],
        ),
        DrogeriePhrase(
          id: 'pcl_refill',
          category: DrogerieCategory.personalCare,
          german: 'Gibt es für dieses Duschgel eine Nachfüllpackung?',
          arabic: 'هل توجد عبوة إعادة تعبئة لجل الاستحمام هذا؟',
          tags: <String>['Duschgel', 'Nachfüllpackung'],
        ),
        DrogeriePhrase(
          id: 'pcl_dm_collect',
          category: DrogerieCategory.loyalty,
          brand: DrogerieBrand.dm,
          german: 'Wie kann ich bei dm PAYBACK Punkte sammeln?',
          arabic: 'كيف يمكنني جمع نقاط PAYBACK لدى dm؟',
          tags: <String>['dm', 'PAYBACK', 'Punkte', 'نقاط'],
        ),
        DrogeriePhrase(
          id: 'pcl_dm_redeem',
          category: DrogerieCategory.loyalty,
          brand: DrogerieBrand.dm,
          german: 'Kann ich meine PAYBACK Punkte an der Kasse einlösen?',
          arabic: 'هل يمكنني استخدام نقاط PAYBACK عند الصندوق؟',
          tags: <String>['dm', 'PAYBACK', 'einlösen', 'Kasse'],
        ),
        DrogeriePhrase(
          id: 'pcl_dm_link',
          category: DrogerieCategory.loyalty,
          brand: DrogerieBrand.dm,
          german: 'Wo verknüpfe ich mein dm-Konto mit PAYBACK?',
          arabic: 'أين أربط حساب dm الخاص بي مع PAYBACK؟',
          tags: <String>['dm-Konto', 'PAYBACK', 'verknüpfen'],
        ),
        DrogeriePhrase(
          id: 'pcl_rossmann_coupon',
          category: DrogerieCategory.loyalty,
          brand: DrogerieBrand.rossmann,
          german: 'Wie aktiviere ich einen Coupon in der ROSSMANN-App?',
          arabic: 'كيف أفعّل كوبوناً في تطبيق ROSSMANN؟',
          tags: <String>['ROSSMANN-App', 'Coupon', 'aktivieren'],
        ),
        DrogeriePhrase(
          id: 'pcl_rossmann_card',
          category: DrogerieCategory.loyalty,
          brand: DrogerieBrand.rossmann,
          german: 'Wo finde ich meine digitale Kundenkarte in der ROSSMANN-App?',
          arabic: 'أين أجد بطاقة العميل الرقمية في تطبيق ROSSMANN؟',
          tags: <String>['ROSSMANN-App', 'Kundenkarte', 'digital'],
        ),
        DrogeriePhrase(
          id: 'pcl_rossmann_loyalty',
          category: DrogerieCategory.loyalty,
          brand: DrogerieBrand.rossmann,
          german: 'Wie funktioniert diese Treueaktion und wo sehe ich meine Punkte?',
          arabic: 'كيف يعمل عرض الولاء هذا وأين أرى نقاطي؟',
          tags: <String>['Treueaktion', 'Punkte', 'ROSSMANN-App', 'نقاط'],
        ),
        DrogeriePhrase(
          id: 'pcl_rossmann_receipt',
          category: DrogerieCategory.loyalty,
          brand: DrogerieBrand.rossmann,
          german: 'Wird der digitale Bon in der App gespeichert?',
          arabic: 'هل يتم حفظ الإيصال الرقمي في التطبيق؟',
          tags: <String>['digitaler Bon', 'App', 'ROSSMANN'],
        ),
      ];

  List<DrogeriePhrase> search(
    String query, {
    DrogerieBrand? brand,
  }) =>
      List<DrogeriePhrase>.unmodifiable(
        items.where(
          (item) =>
              (brand == null ||
                  item.brand == DrogerieBrand.neutral ||
                  item.brand == brand) &&
              item.matches(query),
        ),
      );
}
