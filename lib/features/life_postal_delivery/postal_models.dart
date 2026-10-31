enum PostalCarrier {
  dhl,
  hermes,
  deutschePost;

  String get labelDe => switch (this) {
        PostalCarrier.dhl => 'DHL',
        PostalCarrier.hermes => 'Hermes',
        PostalCarrier.deutschePost => 'Deutsche Post',
      };
}

enum PostalServiceArea {
  shipping,
  packstationIssues;

  String get labelDe => switch (this) {
        PostalServiceArea.shipping => 'Versenden & Abholen',
        PostalServiceArea.packstationIssues => 'Packstation & Zustellung',
      };

  String get labelAr => switch (this) {
        PostalServiceArea.shipping => 'الإرسال والاستلام',
        PostalServiceArea.packstationIssues => 'باك شتيشن ومشاكل التسليم',
      };
}

final class PostalTrackingNumber {
  const PostalTrackingNumber({
    required this.carrier,
    required this.value,
  });

  final PostalCarrier carrier;
  final String value;

  String get normalized =>
      value.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
}

final class ParcelDimensions {
  const ParcelDimensions({
    required this.lengthCm,
    required this.widthCm,
    required this.heightCm,
    required this.weightKg,
  })  : assert(lengthCm > 0),
        assert(widthCm > 0),
        assert(heightCm > 0),
        assert(weightKg > 0);

  final double lengthCm;
  final double widthCm;
  final double heightCm;
  final double weightKg;

  String get dimensionLabelDe =>
      '${_number(lengthCm)} × ${_number(widthCm)} × ${_number(heightCm)} cm';

  String get weightLabelDe => '${_number(weightKg)} kg';

  static String _number(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '');
  }
}

final class DeliveryNotificationCard {
  const DeliveryNotificationCard({
    required this.carrier,
    required this.pickupLocation,
    required this.pickupDeadline,
    required this.referenceNumber,
  });

  final PostalCarrier carrier;
  final String pickupLocation;
  final String pickupDeadline;
  final String referenceNumber;
}

final class PostalHubAction {
  const PostalHubAction({
    required this.id,
    required this.area,
    required this.titleDe,
    required this.titleAr,
    required this.descriptionDe,
    required this.descriptionAr,
    this.keywords = const <String>[],
  });

  final String id;
  final PostalServiceArea area;
  final String titleDe;
  final String titleAr;
  final String descriptionDe;
  final String descriptionAr;
  final List<String> keywords;

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    return <String>[
      titleDe,
      titleAr,
      descriptionDe,
      descriptionAr,
      ...keywords,
    ].join(' ').toLowerCase().contains(needle);
  }
}
