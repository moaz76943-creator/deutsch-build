import '../drogerie_models.dart';

final class HouseholdCleaningAgent {
  const HouseholdCleaningAgent();

  List<DrogeriePhrase> get items => const <DrogeriePhrase>[
        DrogeriePhrase(
          id: 'hc_color',
          category: DrogerieCategory.householdCleaning,
          german: 'Wo finde ich Buntwaschmittel?',
          arabic: 'أين أجد منظف الغسيل للملابس الملونة؟',
          tags: <String>['Buntwaschmittel', 'Waschmittel', 'منظف'],
        ),
        DrogeriePhrase(
          id: 'hc_delicate',
          category: DrogerieCategory.householdCleaning,
          german: 'Ich brauche Feinwaschmittel für empfindliche Textilien.',
          arabic: 'أحتاج إلى منظف لطيف للأقمشة الحساسة.',
          tags: <String>['Feinwaschmittel', 'Textilien', 'empfindlich'],
        ),
        DrogeriePhrase(
          id: 'hc_allpurpose',
          category: DrogerieCategory.householdCleaning,
          german: 'Ist dieser Allzweckreiniger für Küche und Bad geeignet?',
          arabic: 'هل هذا المنظف متعدد الاستخدامات مناسب للمطبخ والحمام؟',
          tags: <String>['Allzweckreiniger', 'Küche', 'Bad', 'منظف'],
        ),
        DrogeriePhrase(
          id: 'hc_descaler',
          category: DrogerieCategory.householdCleaning,
          german: 'Wo steht Entkalker für Wasserkocher?',
          arabic: 'أين يوجد مزيل التكلس لغلاية الماء؟',
          tags: <String>['Entkalker', 'Wasserkocher'],
        ),
        DrogeriePhrase(
          id: 'hc_dosage',
          category: DrogerieCategory.householdCleaning,
          german: 'Wo finde ich die Dosierung auf der Packung?',
          arabic: 'أين أجد تعليمات الجرعة على العبوة؟',
          tags: <String>['Dosierung', 'Packung'],
        ),
        DrogeriePhrase(
          id: 'hc_refill',
          category: DrogerieCategory.householdCleaning,
          german: 'Gibt es davon einen Nachfüllbeutel?',
          arabic: 'هل توجد عبوة إعادة تعبئة لهذا المنتج؟',
          tags: <String>['Nachfüllbeutel', 'Nachfüllen'],
        ),
        DrogeriePhrase(
          id: 'hc_gloves',
          category: DrogerieCategory.householdCleaning,
          german: 'Wo finde ich Haushaltshandschuhe?',
          arabic: 'أين أجد قفازات التنظيف المنزلية؟',
          tags: <String>['Haushaltshandschuhe', 'Reinigung'],
        ),
        DrogeriePhrase(
          id: 'hc_surface',
          category: DrogerieCategory.householdCleaning,
          german: 'Ist das Produkt für diese Oberfläche geeignet?',
          arabic: 'هل هذا المنتج مناسب لهذا السطح؟',
          tags: <String>['Oberfläche', 'geeignet'],
        ),
      ];

  List<DrogeriePhrase> search(String query) =>
      List<DrogeriePhrase>.unmodifiable(
        items.where((item) => item.matches(query)),
      );
}
