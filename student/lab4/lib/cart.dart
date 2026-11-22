// cart.dart: shopping-cart logic, written to be unit-tested
double cartTotal(List<double> prices, {double taxRate = 0.05,
    String? coupon}) {
  if (prices.any((p) => p < 0)) {
    throw ArgumentError('Prices cannot be negative');
  }
  var subtotal = prices.fold(0.0, (sum, p) => sum + p);
  if (coupon == 'GOMAL10') subtotal *= 0.9; // 10% discount
  final total = subtotal * (1 + taxRate);
  return (total * 100).round() / 100; // round to 2 decimal places
}
