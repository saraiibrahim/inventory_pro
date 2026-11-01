import 'package:inventory_pro/data/datasources/sqflite_helper.dart';
import 'package:inventory_pro/data/models/product_model.dart';

class ProductRepository {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<List<ProductModel>> fetchProducts() async {
    return await dbHelper.getAllProducts();
  }

  Future<int> addProduct(ProductModel product) async {
    return await dbHelper.insertProduct(product);
  }

  Future<int> updateProduct(ProductModel product) async {
    return await dbHelper.updateProduct(product);
  }

  Future<int> deleteProduct(int id) async {
    return await dbHelper.deleteProduct(id);
  }
}
