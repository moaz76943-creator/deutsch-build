final class SalonPaymentSummary {
  SalonPaymentSummary({
    required this.serviceTotal,
    required this.tip,
    this.receiptRequested = false,
  }) {
    if (serviceTotal < 0) {
      throw ArgumentError.value(serviceTotal, 'serviceTotal', 'must be >= 0');
    }
    if (tip < 0) {
      throw ArgumentError.value(tip, 'tip', 'must be >= 0');
    }
  }

  final double serviceTotal;
  final double tip;
  final bool receiptRequested;

  double get total => serviceTotal + tip;

  SalonPaymentSummary copyWith({
    double? serviceTotal,
    double? tip,
    bool? receiptRequested,
  }) =>
      SalonPaymentSummary(
        serviceTotal: serviceTotal ?? this.serviceTotal,
        tip: tip ?? this.tip,
        receiptRequested: receiptRequested ?? this.receiptRequested,
      );
}
