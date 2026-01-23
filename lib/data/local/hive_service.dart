import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String categoryBox = 'categories';
  static const String transactionBox = 'transactions';
  static const String budgetBox = 'budgets';
  static const String settingsBox = 'settings';
  static const String reminderBox = 'reminders';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(categoryBox);
    await Hive.openBox<Map>(transactionBox);
    await Hive.openBox<Map>(budgetBox);
    await Hive.openBox<Map>(settingsBox);
    await Hive.openBox<Map>(reminderBox);
  }
}
