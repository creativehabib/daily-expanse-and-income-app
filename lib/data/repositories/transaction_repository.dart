import 'package:hive_flutter/hive_flutter.dart';

import '../../data/local/hive_service.dart';
import '../../domain/models/transaction_entry.dart';

class TransactionRepository {
  final Box<Map> _box = Hive.box<Map>(HiveService.transactionBox);
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
}
