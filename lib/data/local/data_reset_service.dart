import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/models/app_settings.dart';
import '../local/hive_service.dart';
import '../repositories/category_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/transaction_repository.dart';

class DataResetService {
  Future<void> resetToDefaults() async {
    final categoryBox = Hive.box<Map>(HiveService.categoryBox);
    final transactionBox = Hive.box<Map>(HiveService.transactionBox);
    final budgetBox = Hive.box<Map>(HiveService.budgetBox);
    final settingsBox = Hive.box<Map>(HiveService.settingsBox);

    await Future.wait([
      categoryBox.clear(),
      transactionBox.clear(),
      budgetBox.clear(),
      settingsBox.clear(),
    ]);

    final categoryRepository = CategoryRepository();
    final transactionRepository = TransactionRepository();
    final settingsRepository = SettingsRepository();

    await categoryRepository.seedDefaultCategories();
    await transactionRepository.seedSampleTransactions();
    await settingsRepository.saveSettings(AppSettings.defaults);
  }
}
