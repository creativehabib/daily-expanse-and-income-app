import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../data/local/hive_service.dart';
import '../../domain/models/category.dart';

class CategoryRepository {
  final Box<Map> _box = Hive.box<Map>(HiveService.categoryBox);
  final Uuid _uuid = const Uuid();

  List<Category> getAll() {
    return _box.values
        .map((value) => Category.fromMap(Map<String, dynamic>.from(value)))
        .toList();
  }

  Future<void> add(Category category) async {
    await _box.put(category.id, category.toMap());
  }

  Future<void> update(Category category) async {
    await _box.put(category.id, category.toMap());
  }

  Future<void> remove(String id) async {
    await _box.delete(id);
  }

  Future<void> seedDefaultCategories() async {
    if (_box.isNotEmpty) {
      return;
    }

    final defaults = [
      Category(
        id: _uuid.v4(),
        name: 'Groceries',
        type: 'expense',
        icon: Icons.shopping_cart.codePoint,
        color: Colors.green.value,
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      Category(
        id: _uuid.v4(),
        name: 'Transport',
        type: 'expense',
        icon: Icons.directions_bus.codePoint,
        color: Colors.blue.value,
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      Category(
        id: _uuid.v4(),
        name: 'Salary',
        type: 'income',
        icon: Icons.account_balance_wallet.codePoint,
        color: Colors.orange.value,
        isDefault: true,
        createdAt: DateTime.now(),
      ),
    ];

    for (final category in defaults) {
      await add(category);
    }
  }
}
