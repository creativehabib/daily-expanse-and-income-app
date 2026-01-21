class TransactionEntry {
  final String id;
  final String type;
  final double amount;
  final String categoryId;
  final String note;
  final DateTime date;
  final String? paymentMethod;
  final DateTime createdAt;

  const TransactionEntry({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.note,
    required this.date,
    required this.paymentMethod,
    required this.createdAt,
  });

  TransactionEntry copyWith({
    String? id,
    String? type,
    double? amount,
    String? categoryId,
    String? note,
    DateTime? date,
    String? paymentMethod,
    DateTime? createdAt,
  }) {
    return TransactionEntry(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'categoryId': categoryId,
      'note': note,
      'date': date.toIso8601String(),
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TransactionEntry.fromMap(Map<dynamic, dynamic> map) {
    return TransactionEntry(
      id: map['id'] as String,
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      categoryId: map['categoryId'] as String,
      note: map['note'] as String? ?? '',
      date: DateTime.parse(map['date'] as String),
      paymentMethod: map['paymentMethod'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
