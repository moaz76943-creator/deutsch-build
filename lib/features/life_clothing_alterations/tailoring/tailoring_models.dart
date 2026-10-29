enum TailoringService {
  trousersShortening('Hose kürzen', 'تقصير البنطال'),
  sleeveAdjustment('Ärmel anpassen', 'تعديل الأكمام'),
  zipperRepair('Reißverschluss reparieren', 'تصليح السحّاب'),
  pocketRepair('Tasche reparieren', 'تصليح الجيب'),
  buttonRepair('Knopf annähen', 'تثبيت الزر');

  final String german;
  final String arabic;
  const TailoringService(this.german, this.arabic);
}

final class TailoringDialogue {
  final String id;
  final TailoringService service;
  final String german;
  final String arabic;
  final Set<String> keywords;

  const TailoringDialogue({
    required this.id,
    required this.service,
    required this.german,
    required this.arabic,
    required this.keywords,
  });
}

final class TailoringAgreement {
  final TailoringService service;
  final String readyWhenDe;
  final String readyWhenAr;
  final String costQuestionDe;
  final String costQuestionAr;

  const TailoringAgreement({
    required this.service,
    required this.readyWhenDe,
    required this.readyWhenAr,
    required this.costQuestionDe,
    required this.costQuestionAr,
  });
}
