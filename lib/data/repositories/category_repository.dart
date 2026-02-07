import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
        icon: FontAwesomeIcons.utensils.codePoint,
        iconFamily: FontAwesomeIcons.utensils.fontFamily,
        iconPackage: FontAwesomeIcons.utensils.fontPackage,
        color: Colors.green.value,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Transport',
        type: 'expense',
        icon: FontAwesomeIcons.bus.codePoint,
        iconFamily: FontAwesomeIcons.bus.fontFamily,
        iconPackage: FontAwesomeIcons.bus.fontPackage,
        color: Colors.blue.value,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Rent',
        type: 'expense',
        icon: FontAwesomeIcons.house.codePoint,
        iconFamily: FontAwesomeIcons.house.fontFamily,
        iconPackage: FontAwesomeIcons.house.fontPackage,
        color: Colors.brown.value,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Shopping',
        type: 'expense',
        icon: FontAwesomeIcons.cartShopping.codePoint,
        iconFamily: FontAwesomeIcons.cartShopping.fontFamily,
        iconPackage: FontAwesomeIcons.cartShopping.fontPackage,
        color: Colors.pink.value,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Bills',
        type: 'expense',
        icon: FontAwesomeIcons.fileInvoiceDollar.codePoint,
        iconFamily: FontAwesomeIcons.fileInvoiceDollar.fontFamily,
        iconPackage: FontAwesomeIcons.fileInvoiceDollar.fontPackage,
        color: Colors.deepPurple.value,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Salary',
        type: 'income',
        icon: FontAwesomeIcons.wallet.codePoint,
        iconFamily: FontAwesomeIcons.wallet.fontFamily,
        iconPackage: FontAwesomeIcons.wallet.fontPackage,
        color: Colors.orange.value,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Others',
        type: 'expense',
        icon: FontAwesomeIcons.shapes.codePoint,
        iconFamily: FontAwesomeIcons.shapes.fontFamily,
        iconPackage: FontAwesomeIcons.shapes.fontPackage,
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
