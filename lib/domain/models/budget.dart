class Budget {
  final String id;
  final int month;
  final int year;
  final double totalBudget;
  final Map<String, double> categoryBudgets;

  const Budget({
    required this.id,
    required this.month,
    required this.year,
    required this.totalBudget,
    required this.categoryBudgets,
  });

  Budget copyWith({
    String? id,
    int? month,
    int? year,
    double? totalBudget,
    Map<String, double>? categoryBudgets,
  }) {
    return Budget(
      id: id ?? this.id,
      month: month ?? this.month,
      year: year ?? this.year,
      totalBudget: totalBudget ?? this.totalBudget,
      categoryBudgets: categoryBudgets ?? this.categoryBudgets,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'month': month,
      'year': year,
      'totalBudget': totalBudget,
      'categoryBudgets': categoryBudgets,
    };
  }

  factory Budget.fromMap(Map<dynamic, dynamic> map) {
    final raw = map['categoryBudgets'] as Map<dynamic, dynamic>? ?? {};
    return Budget(
      id: map['id'] as String,
      month: map['month'] as int,
      year: map['year'] as int,
      totalBudget: (map['totalBudget'] as num).toDouble(),
      categoryBudgets: raw.map((key, value) => MapEntry(
            key.toString(),
            (value as num).toDouble(),
          )),
    );
  }
}
