enum HardwareStoreSection { toolsMaterials, cuttingRental }

extension HardwareStoreSectionLabels on HardwareStoreSection {
  String get labelDe => switch (this) {
        HardwareStoreSection.toolsMaterials => 'Werkzeuge & Materialien',
        HardwareStoreSection.cuttingRental => 'Zuschnitt & Mietgeräte',
      };

  String get labelAr => switch (this) {
        HardwareStoreSection.toolsMaterials => 'الأدوات والمواد',
        HardwareStoreSection.cuttingRental => 'القص وتأجير المعدات',
      };
}

enum HardwareStoreItemKind { tool, material, cuttingService, rentalService }

extension HardwareStoreItemKindLabels on HardwareStoreItemKind {
  String get labelDe => switch (this) {
        HardwareStoreItemKind.tool => 'Werkzeug',
        HardwareStoreItemKind.material => 'Material',
        HardwareStoreItemKind.cuttingService => 'Zuschnittservice',
        HardwareStoreItemKind.rentalService => 'Mietservice',
      };

  String get labelAr => switch (this) {
        HardwareStoreItemKind.tool => 'أداة',
        HardwareStoreItemKind.material => 'مادة',
        HardwareStoreItemKind.cuttingService => 'خدمة قص',
        HardwareStoreItemKind.rentalService => 'خدمة تأجير',
      };
}

final class HardwareStoreCatalogItem {
  const HardwareStoreCatalogItem({
    required this.id,
    required this.kind,
    required this.nameDe,
    required this.nameAr,
    required this.noteDe,
    required this.noteAr,
  });

  final String id;
  final HardwareStoreItemKind kind;
  final String nameDe;
  final String nameAr;
  final String noteDe;
  final String noteAr;
}
