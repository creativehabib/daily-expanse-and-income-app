import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/budget_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/models/budget.dart';
import '../../domain/models/category.dart';
import '../../domain/models/transaction_entry.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(ref.read(settingsRepositoryProvider)),
);

final balancePrivacyModeProvider =
    StateNotifierProvider<BalancePrivacyModeNotifier, bool>(
  (ref) => BalancePrivacyModeNotifier(ref.read(settingsRepositoryProvider)),
);

final categoriesProvider = StateNotifierProvider<CategoryNotifier, List<Category>>(
  (ref) => CategoryNotifier(ref.read(categoryRepositoryProvider)),
);

final transactionsProvider =
    StateNotifierProvider<TransactionNotifier, List<TransactionEntry>>(
  (ref) => TransactionNotifier(ref.read(transactionRepositoryProvider)),
);

final budgetProvider = FutureProvider<Budget?>((ref) async {
  final repo = ref.read(budgetRepositoryProvider);
  final now = DateTime.now();
  return repo.getByMonth(now.month, now.year);
});

class CategoryNotifier extends StateNotifier<List<Category>> {
  CategoryNotifier(this._repository) : super([]) {
    load();
  }

  final CategoryRepository _repository;

  void load() {
    state = _repository.getAll();
  }

  Future<void> add(Category category) async {
    await _repository.add(category);
    load();
  }

  Future<void> update(Category category) async {
    await _repository.update(category);
    load();
  }

  Future<void> remove(String id) async {
    await _repository.remove(id);
    load();
  }
}

class TransactionNotifier extends StateNotifier<List<TransactionEntry>> {
  TransactionNotifier(this._repository) : super([]) {
    load();
  }

  final TransactionRepository _repository;

  void load() {
    state = _repository.getAll();
  }

  Future<void> add(TransactionEntry entry) async {
    await _repository.add(entry);
    load();
  }

  Future<void> update(TransactionEntry entry) async {
    await _repository.update(entry);
    load();
  }

  Future<void> remove(String id) async {
    await _repository.remove(id);
    load();
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier(this._repository) : super(_repository.getSettings());

  final SettingsRepository _repository;

  Future<void> updateSettings(AppSettings settings) async {
    state = settings;
    await _repository.saveSettings(settings);
  }
}

class BalancePrivacyModeNotifier extends StateNotifier<bool> {
  BalancePrivacyModeNotifier(this._repository)
      : super(_repository.getBalancePrivacyMode());

  final SettingsRepository _repository;

  Future<void> setEnabled(bool value) async {
    state = value;
    await _repository.saveBalancePrivacyMode(value);
  }
}
