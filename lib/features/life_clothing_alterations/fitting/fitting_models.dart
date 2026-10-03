enum FittingGarmentType {
  jacket('Jacke', 'سترة'),
  shirt('Hemd', 'قميص'),
  trousers('Hose', 'بنطال');

  final String german;
  final String arabic;
  const FittingGarmentType(this.german, this.arabic);
}

enum NaturalFabric {
  cotton('Baumwolle', 'قطن'),
  wool('Wolle', 'صوف');

  final String german;
  final String arabic;
  const NaturalFabric(this.german, this.arabic);
}

enum FitDimension {
  length('Länge', 'الطول'),
  width('Weite', 'العرض'),
  comfort('bequemer Sitz', 'الراحة');

  final String german;
  final String arabic;
  const FitDimension(this.german, this.arabic);
}

final class FittingDialogue {
  final String id;
  final FittingGarmentType garment;
  final String german;
  final String arabic;
  final Set<String> keywords;

  const FittingDialogue({
    required this.id,
    required this.garment,
    required this.german,
    required this.arabic,
    required this.keywords,
  });
}

final class FabricCareNote {
  final NaturalFabric fabric;
  final String materialQuestionDe;
  final String materialQuestionAr;
  final String careQuestionDe;
  final String careQuestionAr;

  const FabricCareNote({
    required this.fabric,
    required this.materialQuestionDe,
    required this.materialQuestionAr,
    required this.careQuestionDe,
    required this.careQuestionAr,
  });
}
