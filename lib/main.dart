import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/local/hive_service.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/transaction_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();

  final categoryRepository = CategoryRepository();
  final transactionRepository = TransactionRepository();
  await categoryRepository.seedDefaultCategories();
  await transactionRepository.seedSampleTransactions();

  runApp(const ProviderScope(child: ExpenseApp()));
}
