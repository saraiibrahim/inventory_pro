enum TransactionStatus { paid, partial, pending }

class TransactionModel {
  final int id;
  final String entityName;
  final String date;
  final double amount;
  final bool isIncome;
  final TransactionStatus status;
  final int timestamp;
  final int quantityChange;
  final int productId;

  TransactionModel({
    this.id = 0,
    required this.entityName,
    required this.date,
    required this.amount,
    required this.isIncome,
    required this.status,
    required this.timestamp,
    this.quantityChange = 0,
    required this.productId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entityName': entityName,
      'date': date,
      'amount': amount,
      'isIncome': isIncome ? 1 : 0,
      'status': status.name,
      'timestamp': timestamp,
      'quantityChange': quantityChange,
      'productId': productId,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int? ?? 0,
      entityName: map['entityName'] ?? '',
      date: map['date'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      isIncome: (map['isIncome'] as int? ?? 0) == 1,
      status: TransactionStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => TransactionStatus.pending,
      ),
      timestamp: map['timestamp'] as int? ?? 0,
      quantityChange: map['quantityChange'] as int? ?? 0,
      productId: map['productId'] as int? ?? 0,
    );
  }
}
