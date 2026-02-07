import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/transaction_entry.dart';
import 'providers.dart';

enum DateRangePreset {
  allTime,
  thisWeek,
  thisMonth,
  lastMonth,
  thisYear,
  custom,
}

class DateRangeState {
  const DateRangeState({
    required this.preset,
    this.range,
  });

  final DateRangePreset preset;
  final DateTimeRange? range;
}

class DateRangeNotifier extends StateNotifier<DateRangeState> {
  DateRangeNotifier()
      : super(const DateRangeState(preset: DateRangePreset.allTime));

  void setPreset(DateRangePreset preset) {
    if (preset == DateRangePreset.allTime) {
      state = const DateRangeState(preset: DateRangePreset.allTime, range: null);
      return;
    }

    final now = DateTime.now();
    DateTimeRange range;

    switch (preset) {
      case DateRangePreset.thisWeek:
        final start = now.subtract(Duration(days: now.weekday - 1));
        range = DateTimeRange(
          start: DateTime(start.year, start.month, start.day),
          end: DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
        break;
      case DateRangePreset.thisMonth:
        range = DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );
        break;
      case DateRangePreset.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        range = DateTimeRange(
          start: DateTime(lastMonth.year, lastMonth.month, 1),
          end: DateTime(lastMonth.year, lastMonth.month + 1, 0, 23, 59, 59),
        );
        break;
      case DateRangePreset.thisYear:
        range = DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: DateTime(now.year, 12, 31, 23, 59, 59),
        );
        break;
      case DateRangePreset.custom:
      case DateRangePreset.allTime:
        return;
    }

    state = DateRangeState(preset: preset, range: range);
  }

  void setCustomRange(DateTimeRange range) {
    state = DateRangeState(preset: DateRangePreset.custom, range: range);
  }
}

final dateRangeProvider =
    StateNotifierProvider<DateRangeNotifier, DateRangeState>(
  (ref) => DateRangeNotifier(),
);

final filteredTransactionsProvider = Provider<List<TransactionEntry>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final filter = ref.watch(dateRangeProvider);

  final range = filter.range;
  if (range == null) {
    return transactions;
  }

  return transactions
      .where((entry) =>
          !entry.date.isBefore(range.start) &&
          !entry.date.isAfter(range.end))
      .toList();
});

final orderedTransactionsProvider = Provider<List<TransactionEntry>>((ref) {
  final transactions = ref.watch(filteredTransactionsProvider);
  final ordered = [...transactions]
    ..sort((a, b) => b.date.compareTo(a.date));
  return ordered;
});
