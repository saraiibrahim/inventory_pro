import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_pro/data/models/transaction_model.dart';
import 'package:inventory_pro/data/repositories/transaction_repository.dart';

abstract class TransactionState {}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<TransactionModel> transactions;
  TransactionLoaded(this.transactions);
}

class TransactionError extends TransactionState {
  final String message;
  TransactionError(this.message);
}

class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepository repository;

  TransactionCubit(this.repository) : super(TransactionInitial());

  Future<void> loadTransactions() async {
    emit(TransactionLoading());
    try {
      final txs = await repository.fetchTransactions();
      emit(TransactionLoaded(txs));
    } catch (e) {
      emit(TransactionError("فشل في تحميل المعاملات: ${e.toString()}"));
    }
  }

  Future<void> addTransaction(TransactionModel tx) async {
    try {
      await repository.addTransaction(tx);
      await loadTransactions();
    } catch (e) {
      emit(TransactionError("فشل إضافة المعاملة"));
    }
  }
}
