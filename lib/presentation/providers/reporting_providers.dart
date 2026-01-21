import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/transaction_entry.dart';
import 'date_filter_provider.dart';

class IncomeExpenseSummary {
  const IncomeExpenseSummary({
    required this.income,
    required this.expense,
  });

  final double income;
  final double expense;
}

class MonthlySpending {
  const MonthlySpending({
    required this.month,
    required this.total,
  });

  final DateTime month;
  final double total;
}

final incomeExpenseSummaryProvider = Provider<IncomeExpenseSummary>((ref) {
  final transactions = ref.watch(filteredTransactionsProvider);

  final income = transactions
      .where((entry) => entry.type == 'income')
      .fold<double>(0, (sum, entry) => sum + entry.amount);

  final expense = transactions
      .where((entry) => entry.type == 'expense')
      .fold<double>(0, (sum, entry) => sum + entry.amount);

  return IncomeExpenseSummary(income: income, expense: expense);
});

final monthlySpendingProvider = Provider<List<MonthlySpending>>((ref) {
  final transactions = ref.watch(filteredTransactionsProvider);
  final range = ref.watch(dateRangeProvider).range;

  final monthStarts = _monthStartsForRange(range);

  return monthStarts
      .map(
        (month) => MonthlySpending(
          month: month,
          total: _monthlyTotal(transactions, month),
        ),
      )
      .toList();
});

List<DateTime> _monthStartsForRange(DateTimeRange? range) {
  if (range == null) {
    final now = DateTime.now();
    return List.generate(6, (index) {
      final monthOffset = 5 - index;
      return DateTime(now.year, now.month - monthOffset, 1);
    });
  }

  final start = DateTime(range.start.year, range.start.month, 1);
  final end = DateTime(range.end.year, range.end.month, 1);
  final months = <DateTime>[];

  var cursor = start;
  while (!cursor.isAfter(end)) {
    months.add(cursor);
    cursor = DateTime(cursor.year, cursor.month + 1, 1);
  }

  return months;
}

double _monthlyTotal(List<TransactionEntry> transactions, DateTime month) {
  final monthStart = DateTime(month.year, month.month, 1);
  final monthEnd = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

  return transactions
      .where((entry) => entry.type == 'expense')
      .where((entry) =>
          !entry.date.isBefore(monthStart) &&
          !entry.date.isAfter(monthEnd))
      .fold<double>(0, (sum, entry) => sum + entry.amount);
}
