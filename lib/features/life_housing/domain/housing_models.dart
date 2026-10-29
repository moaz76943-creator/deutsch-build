enum HousingCategory {
  apartmentHunting,
  maintenanceRepair,
}

enum HousingLevel {
  a1a2,
  b1,
  b2,
}

enum HousingQuickAction {
  contactLandlord,
  askAboutKaution,
  reportPlumbing,
  reportHeating,
  arrangeInternet,
}

extension HousingCategoryLabels on HousingCategory {
  String get germanLabel => switch (this) {
        HousingCategory.apartmentHunting => 'Wohnungssuche',
        HousingCategory.maintenanceRepair => 'Handwerker',
      };

  String get arabicLabel => switch (this) {
        HousingCategory.apartmentHunting => 'البحث عن سكن',
        HousingCategory.maintenanceRepair => 'الصيانة والإصلاح',
      };
}

extension HousingLevelLabels on HousingLevel {
  String get label => switch (this) {
        HousingLevel.a1a2 => 'A1/A2',
        HousingLevel.b1 => 'B1',
        HousingLevel.b2 => 'B2',
      };
}

extension HousingQuickActionLabels on HousingQuickAction {
  String get germanLabel => switch (this) {
        HousingQuickAction.contactLandlord => 'Vermieter kontaktieren',
        HousingQuickAction.askAboutKaution => 'Kaution fragen',
        HousingQuickAction.reportPlumbing => 'Wasserproblem melden',
        HousingQuickAction.reportHeating => 'Heizung melden',
        HousingQuickAction.arrangeInternet => 'Internet-Termin',
      };

  String get arabicLabel => switch (this) {
        HousingQuickAction.contactLandlord => 'التواصل مع المؤجر',
        HousingQuickAction.askAboutKaution => 'السؤال عن التأمين',
        HousingQuickAction.reportPlumbing => 'بلاغ مشكلة مياه',
        HousingQuickAction.reportHeating => 'بلاغ التدفئة',
        HousingQuickAction.arrangeInternet => 'موعد تركيب الإنترنت',
      };
}

final class HousingPhrase {
  const HousingPhrase({
    required this.id,
    required this.category,
    required this.level,
    required this.titleDe,
    required this.textDe,
    required this.explanationAr,
  });

  final String id;
  final HousingCategory category;
  final HousingLevel level;
  final String titleDe;
  final String textDe;
  final String explanationAr;
}
