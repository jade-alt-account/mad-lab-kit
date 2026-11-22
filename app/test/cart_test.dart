// cart_test.dart: unit tests for the cart logic
import 'package:flutter_test/flutter_test.dart';
import 'package:gomal_mad_labs/cart.dart';

void main() {
  test('adds 5% tax to the subtotal', () {
    expect(cartTotal([100, 200]), 315.0);
  });

  test('applies the GOMAL10 coupon before tax', () {
    expect(cartTotal([100], coupon: 'GOMAL10'), 94.5);
  });

  test('an empty cart costs nothing', () {
    expect(cartTotal([]), 0.0);
  });

  test('rejects negative prices', () {
    expect(() => cartTotal([-5]), throwsArgumentError);
  });
}
