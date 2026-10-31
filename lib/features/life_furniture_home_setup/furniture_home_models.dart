enum FurnitureHomeSection { shopping, delivery, warranty }

enum FurnitureRequestStatus { planning, ordered, delivered, issueReported }

final class FurniturePurchaseRequest {
  const FurniturePurchaseRequest({
    required this.id,
    required this.itemNameDe,
    required this.itemNameAr,
    required this.quantity,
    this.widthCm,
    this.heightCm,
    this.depthCm,
    this.status = FurnitureRequestStatus.planning,
  });

  final String id;
  final String itemNameDe;
  final String itemNameAr;
  final int quantity;
  final double? widthCm;
  final double? heightCm;
  final double? depthCm;
  final FurnitureRequestStatus status;

  String get dimensionsLabel {
    final values = <String>[
      if (heightCm != null) 'Höhe ${_format(heightCm!)} cm',
      if (widthCm != null) 'Breite ${_format(widthCm!)} cm',
      if (depthCm != null) 'Tiefe ${_format(depthCm!)} cm',
    ];
    return values.isEmpty ? 'Maße noch offen' : values.join(' · ');
  }

  static String _format(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
}

enum FurnitureDeliveryLevel { curbside, apartment }

final class FurnitureDeliveryRequest {
  const FurnitureDeliveryRequest({
    required this.orderId,
    required this.level,
    required this.addressNote,
    this.preferredWindow,
  });

  final String orderId;
  final FurnitureDeliveryLevel level;
  final String addressNote;
  final String? preferredWindow;

  String get labelDe => switch (level) {
        FurnitureDeliveryLevel.curbside =>
          'Lieferung bis zur Bordsteinkante',
        FurnitureDeliveryLevel.apartment =>
          'Lieferung bis in die Wohnung',
      };
}

final class FurnitureWarrantyCase {
  const FurnitureWarrantyCase({
    required this.orderId,
    required this.problemDe,
    required this.problemAr,
    required this.purchaseDate,
    this.receiptAvailable = true,
  });

  final String orderId;
  final String problemDe;
  final String problemAr;
  final DateTime purchaseDate;
  final bool receiptAvailable;

  bool isWithinMonths(int months, DateTime now) {
    final boundary = DateTime(
      purchaseDate.year,
      purchaseDate.month + months,
      purchaseDate.day,
    );
    return !now.isAfter(boundary);
  }
}
