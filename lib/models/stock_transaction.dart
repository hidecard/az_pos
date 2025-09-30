enum StockTransactionType {
  stockIn,
  stockOut,
  adjustment,
}

class StockTransaction {
  final int id;
  final int productId;
  final StockTransactionType type;
  final int quantity;
  final DateTime date;
  final String reason;
  final int? employeeId;

  StockTransaction({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.date,
    this.reason = '',
    this.employeeId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'type': type.index,
      'quantity': quantity,
      'date': date.toIso8601String(),
      'reason': reason,
      'employeeId': employeeId,
    };
  }

  factory StockTransaction.fromMap(Map<String, dynamic> map) {
    return StockTransaction(
      id: map['id'],
      productId: map['productId'],
      type: StockTransactionType.values[map['type']],
      quantity: map['quantity'],
      date: DateTime.parse(map['date']),
      reason: map['reason'] ?? '',
      employeeId: map['employeeId'],
    );
  }
}
