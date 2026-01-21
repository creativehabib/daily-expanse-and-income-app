import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../data/local/hive_service.dart';
import '../../domain/models/budget.dart';

class BudgetRepository {
  final Box<Map> _box = Hive.box<Map>(HiveService.budgetBox);
  final Uuid _uuid = const Uuid();

  Budget? getByMonth(int month, int year) {
    final key = _key(month, year);
    final data = _box.get(key);
    if (data == null) {
      return null;
    }
    return Budget.fromMap(Map<String, dynamic>.from(data));
  }

  Future<void> upsert({
    required int month,
    required int year,
    required double totalBudget,
    Map<String, double> categoryBudgets = const {},
  }) async {
    final budget = Budget(
      id: _uuid.v4(),
      month: month,
      year: year,
      totalBudget: totalBudget,
      categoryBudgets: categoryBudgets,
    );
    await _box.put(_key(month, year), budget.toMap());
  }

  String _key(int month, int year) => '$year-$month';
}
