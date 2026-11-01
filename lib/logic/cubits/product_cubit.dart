import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_pro/data/models/product_model.dart';
import 'package:inventory_pro/data/repositories/product_repository.dart'; // مسار الـ Repository

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<ProductModel> products;
  ProductLoaded(this.products);
}

class ProductError extends ProductState {
  final String message;
  ProductError(this.message);
}

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository repository;

  ProductCubit(this.repository) : super(ProductInitial());

  Future<void> loadProducts() async {
    emit(ProductLoading());
    try {
      final products = await repository.fetchProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError("فشل في تحميل البيانات: ${e.toString()}"));
    }
  }

  Future<void> addProduct(ProductModel product) async {
    try {
      await repository.addProduct(product);
      await loadProducts();
    } catch (e) {
      emit(ProductError("فشل إضافة المنتج"));
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await repository.updateProduct(product);
      await loadProducts();
    } catch (e) {
      emit(ProductError("فشل تعديل المنتج"));
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await repository.deleteProduct(id);
      await loadProducts();
    } catch (e) {
      emit(ProductError("فشل حذف المنتج"));
    }
  }
}
