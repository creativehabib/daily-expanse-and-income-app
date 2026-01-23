import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/local/hive_service.dart';
import 'data/repositories/category_repository.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  await NotificationService.instance.init();

  final categoryRepository = CategoryRepository();
  await categoryRepository.seedDefaultCategories();

  runApp(const ProviderScope(child: ExpenseApp()));
}
