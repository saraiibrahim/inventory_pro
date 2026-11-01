import 'package:inventory_pro/data/datasources/sqflite_helper.dart';
import 'package:inventory_pro/data/models/transaction_model.dart';

class TransactionRepository {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<List<TransactionModel>> fetchTransactions() async {
    return await dbHelper.getAllTransactions();
  }

  Future<int> addTransaction(TransactionModel tx) async {
    return await dbHelper.insertTransaction(tx);
  }
}
