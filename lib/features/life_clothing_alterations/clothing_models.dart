enum ClothingGarment {
  shirt('Hemd', 'قميص'),
  trousers('Hose', 'بنطال'),
  jacket('Jacke', 'سترة'),
  winterCoat('Wintermantel', 'معطف شتوي');

  final String german;
  final String arabic;
  const ClothingGarment(this.german, this.arabic);
}

enum ClothingFabric {
  cotton('Baumwolle', 'قطن'),
  wool('Wolle', 'صوف');

  final String german;
  final String arabic;
  const ClothingFabric(this.german, this.arabic);
}

final class StandardClothingSize {
  final ClothingGarment garment;
  final String label;
  final String euReference;
  final String noteDe;
  final String noteAr;

  const StandardClothingSize({
    required this.garment,
    required this.label,
    required this.euReference,
    required this.noteDe,
    required this.noteAr,
  });
}

final class ClothingFabricInfo {
  final ClothingFabric fabric;
  final String descriptionDe;
  final String descriptionAr;
  final String carePromptDe;
  final String carePromptAr;

  const ClothingFabricInfo({
    required this.fabric,
    required this.descriptionDe,
    required this.descriptionAr,
    required this.carePromptDe,
    required this.carePromptAr,
  });
}

final class AlterationReceipt {
  final String receiptId;
  final ClothingGarment garment;
  final String serviceDe;
  final String serviceAr;
  final DateTime receivedAt;
  final DateTime readyAt;
  final double? agreedPriceEuro;

  const AlterationReceipt({
    required this.receiptId,
    required this.garment,
    required this.serviceDe,
    required this.serviceAr,
    required this.receivedAt,
    required this.readyAt,
    this.agreedPriceEuro,
  });

  bool get isChronologicallyValid => !readyAt.isBefore(receivedAt);
}
