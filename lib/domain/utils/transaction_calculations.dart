import '../models/transaction_entry.dart';

class TransactionCalculations {
  static double dailyTotalExpense(
    List<TransactionEntry> entries,
    DateTime day,
  ) {
    return entries
        .where((entry) => entry.type == 'expense')
        .where((entry) => _isSameDay(entry.date, day))
        .fold(0, (sum, entry) => sum + entry.amount);
  }

  static double monthlyTotal(
    List<TransactionEntry> entries,
    int month,
    int year,
    String type,
  ) {
    return entries
        .where((entry) => entry.type == type)
        .where((entry) => entry.date.month == month && entry.date.year == year)
        .fold(0, (sum, entry) => sum + entry.amount);
  }

  static Map<String, double> categoryTotals(
    List<TransactionEntry> entries,
    String type,
  ) {
    final totals = <String, double>{};
    for (final entry in entries.where((entry) => entry.type == type)) {
      totals.update(entry.categoryId, (value) => value + entry.amount,
          ifAbsent: () => entry.amount);
    }
    return totals;
  }

  static double remainingBudget({
    required double totalBudget,
    required double totalExpense,
  }) {
    return totalBudget - totalExpense;
  }

  static List<TransactionEntry> filterByDateRange(
    List<TransactionEntry> entries,
    DateTime start,
    DateTime end,
  ) {
    return entries
        .where((entry) =>
            entry.date.isAfter(start.subtract(const Duration(days: 1))) &&
            entry.date.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
