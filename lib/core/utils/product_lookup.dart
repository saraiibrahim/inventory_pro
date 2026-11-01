import 'package:inventory_pro/data/models/product_model.dart';
import 'package:inventory_pro/data/models/transaction_model.dart';

ProductModel? findProduct(List<ProductModel> products, TransactionModel t) {
  for (final p in products) {
    final isMatch = t.productId != 0
        ? p.id == t.productId
        : p.name == t.entityName;
    if (isMatch) return p;
  }
  return null; // المنتج اتمسح
}
