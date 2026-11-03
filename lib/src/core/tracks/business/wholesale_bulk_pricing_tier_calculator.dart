class WholesaleBulkPricingTierCalculator {
  double computeDiscountedPrice(double unitPrice, int quantity) {
    if (quantity >= 1000) return unitPrice * 0.80; // 20% discount
    if (quantity >= 500) return unitPrice * 0.90; // 10% discount
    return unitPrice;
  }
}
