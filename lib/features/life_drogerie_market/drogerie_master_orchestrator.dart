import 'drogerie_models.dart';

final class DrogerieMasterOrchestrator {
  const DrogerieMasterOrchestrator();

  List<DrogerieCategory> get categories => DrogerieCategory.values;

  static const List<DrogeriePhrase> _items = <DrogeriePhrase>[
    DrogeriePhrase(
      id: 'clean_detergent',
      category: DrogerieCategory.householdCleaning,
      german: 'Wo finde ich Waschmittel für Buntwäsche?',
      arabic: 'أين أجد منظف الغسيل للملابس الملونة؟',
      tags: <String>['Waschmittel', 'Buntwäsche', 'Reinigung'],
    ),
    DrogeriePhrase(
      id: 'clean_allpurpose',
      category: DrogerieCategory.householdCleaning,
      german: 'Ich suche einen Allzweckreiniger.',
      arabic: 'أبحث عن منظف متعدد الاستخدامات.',
      tags: <String>['Allzweckreiniger', 'Haushalt'],
    ),
    DrogeriePhrase(
      id: 'care_shampoo',
      category: DrogerieCategory.personalCare,
      german: 'Wo stehen Shampoo und Duschgel?',
      arabic: 'أين يوجد الشامبو وجل الاستحمام؟',
      tags: <String>['Shampoo', 'Duschgel', 'Körperpflege'],
    ),
    DrogeriePhrase(
      id: 'care_sensitive',
      category: DrogerieCategory.personalCare,
      german: 'Haben Sie eine parfümfreie Variante für empfindliche Haut?',
      arabic: 'هل لديكم نوع خالٍ من العطر للبشرة الحساسة؟',
      tags: <String>['parfümfrei', 'empfindliche Haut'],
    ),
    DrogeriePhrase(
      id: 'dm_payback',
      category: DrogerieCategory.loyalty,
      brand: DrogerieBrand.dm,
      german: 'Kann ich bei dm PAYBACK Punkte sammeln oder einlösen?',
      arabic: 'هل يمكنني جمع نقاط PAYBACK أو استخدامها لدى dm؟',
      tags: <String>['dm', 'PAYBACK', 'Punkte', 'نقاط'],
    ),
    DrogeriePhrase(
      id: 'rossmann_coupon',
      category: DrogerieCategory.loyalty,
      brand: DrogerieBrand.rossmann,
      german: 'Wo aktiviere ich den Coupon in der ROSSMANN-App?',
      arabic: 'أين أفعّل الكوبون في تطبيق ROSSMANN؟',
      tags: <String>['ROSSMANN', 'App', 'Coupon', 'Treueaktion'],
    ),
  ];

  List<DrogeriePhrase> get allItems =>
      List<DrogeriePhrase>.unmodifiable(_items);

  List<DrogeriePhrase> itemsFor(DrogerieCategory category) =>
      List<DrogeriePhrase>.unmodifiable(
        _items.where((item) => item.category == category),
      );

  List<DrogeriePhrase> search(
    String query, {
    DrogerieCategory? category,
    DrogerieBrand? brand,
  }) =>
      List<DrogeriePhrase>.unmodifiable(
        _items.where(
          (item) =>
              (category == null || item.category == category) &&
              (brand == null ||
                  item.brand == DrogerieBrand.neutral ||
                  item.brand == brand) &&
              item.matches(query),
        ),
      );
}
