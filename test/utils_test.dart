import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_pro/core/utils/compact_number.dart';
import 'package:inventory_pro/core/utils/product_lookup.dart';
import 'package:inventory_pro/core/utils/sales_math.dart';
import 'package:inventory_pro/data/models/product_model.dart';
import 'package:inventory_pro/data/models/transaction_model.dart';

void main() {
  group('SalesMath.percentGrowth', () {
    test('20% growth from 1000 to 1200', () {
      expect(SalesMath.percentGrowth(1200, 1000), closeTo(20.0, 0.001));
    });
    test('returns 0 when previous is 0', () {
      expect(SalesMath.percentGrowth(500, 0), 0.0);
    });
    test('negative growth', () {
      expect(SalesMath.percentGrowth(800, 1000), closeTo(-20.0, 0.001));
    });
  });

  group('SalesMath.monthStart', () {
    test('first day of the same month', () {
      expect(SalesMath.monthStart(DateTime(2026, 3, 15)), DateTime(2026, 3, 1));
    });
    test('crosses the year boundary', () {
      expect(
        SalesMath.monthStart(DateTime(2026, 3, 15), monthsAgo: 3),
        DateTime(2025, 12, 1),
      );
    });
  });

  group('compactNumber', () {
    test('small numbers stay as they are', () {
      expect(compactNumber(0), '0');
      expect(compactNumber(12.5), '12.5');
    });
    test('thousands use k', () => expect(compactNumber(1250), '1.3k'));
    test('millions use M', () => expect(compactNumber(1200000), '1.2M'));
    test(
      'rounding does not give 1000k',
      () => expect(compactNumber(999960), '1M'),
    );
  });

  group('findProduct', () {
    final product = ProductModel(
      id: 5,
      name: 'Bag',
      sku: 'S1',
      price: 10,
      costPrice: 5,
      quantity: 3,
      category: 'Bags',
      image: 'assets/images/1.png',
    );

    TransactionModel tx({int productId = 0, String name = 'x'}) =>
        TransactionModel(
          productId: productId,
          entityName: name,
          date: '',
          amount: 10,
          isIncome: true,
          status: TransactionStatus.paid,
          timestamp: 0,
        );

    test('matches by productId', () {
      expect(findProduct([product], tx(productId: 5, name: 'Old')), product);
    });
    test('falls back to name for old transactions', () {
      expect(findProduct([product], tx(name: 'Bag')), product);
    });
    test('returns null when the product was deleted', () {
      expect(findProduct([], tx(productId: 5)), isNull);
    });
  });
}
