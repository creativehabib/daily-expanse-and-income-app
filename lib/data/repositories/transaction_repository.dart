import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../data/local/hive_service.dart';
import '../../domain/models/category.dart';
import '../../domain/models/transaction_entry.dart';

class TransactionRepository {
  final Box<Map> _box = Hive.box<Map>(HiveService.transactionBox);
  final Uuid _uuid = const Uuid();

  List<TransactionEntry> getAll() {
    return _box.values
        .map((value) =>
            TransactionEntry.fromMap(Map<String, dynamic>.from(value)))
        .toList();
  }

  Future<void> add(TransactionEntry entry) async {
    await _box.put(entry.id, entry.toMap());
  }

  Future<void> update(TransactionEntry entry) async {
    await _box.put(entry.id, entry.toMap());
  }

  Future<void> remove(String id) async {
    await _box.delete(id);
  }

  Future<void> seedSampleTransactions() async {
    if (_box.isNotEmpty) {
      return;
    }

    final now = DateTime.now();
    final categoryBox = Hive.box<Map>(HiveService.categoryBox);
    final categories = categoryBox.values
        .map((value) => Category.fromMap(Map<String, dynamic>.from(value)))
        .toList();
    final expenseCategory = categories.firstWhere(
      (category) => category.type == 'expense',
      orElse: () => categories.first,
    );
    final incomeCategory = categories.firstWhere(
      (category) => category.type == 'income',
      orElse: () => categories.first,
    );
    final samples = [
      TransactionEntry(
        id: _uuid.v4(),
        type: 'expense',
        amount: 250.0,
        categoryId: expenseCategory.id,
        note: 'Sample groceries',
        date: now,
        paymentMethod: 'Cash',
        createdAt: now,
      ),
      TransactionEntry(
        id: _uuid.v4(),
        type: 'income',
        amount: 15000.0,
        categoryId: incomeCategory.id,
        note: 'Sample salary',
        date: now,
        paymentMethod: 'Bank',
        createdAt: now,
      ),
    ];

    for (final entry in samples) {
      await add(entry);
    }
  }
}
