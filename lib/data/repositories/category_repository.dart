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

    final now = DateTime.now();
    final defaults = [
      Category(
        id: _uuid.v4(),
        name: 'Food',
        type: 'expense',
        icon: Icons.restaurant.codePoint,
        color: Colors.green.value,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Transport',
        type: 'expense',
        icon: Icons.directions_bus.codePoint,
        color: Colors.blue.value,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Rent',
        type: 'expense',
        icon: Icons.home.codePoint,
        color: Colors.brown.value,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Shopping',
        type: 'expense',
        icon: Icons.shopping_bag.codePoint,
        color: Colors.pink.value,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Bills',
        type: 'expense',
        icon: Icons.receipt_long.codePoint,
        color: Colors.deepPurple.value,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Salary',
        type: 'income',
        icon: Icons.account_balance_wallet.codePoint,
        color: Colors.orange.value,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Others',
        type: 'expense',
        icon: Icons.category.codePoint,
        color: Colors.teal.value,
        isDefault: true,
        createdAt: now,
      ),
    ];

    for (final category in defaults) {
      await add(category);
    }
  }
}
