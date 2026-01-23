import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/utils/transaction_calculations.dart';
import '../providers/date_filter_provider.dart';
import '../providers/providers.dart';
import '../providers/reporting_providers.dart';
import '../widgets/date_filter_bar.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(filteredTransactionsProvider);
    final summary = ref.watch(incomeExpenseSummaryProvider);
    final monthlySpending = ref.watch(monthlySpendingProvider);
    final categories = ref.watch(categoriesProvider);
    final expenseTransactions =
        transactions.where((entry) => entry.type == 'expense').toList();
    final categoryTotals =
        TransactionCalculations.categoryTotals(expenseTransactions, 'expense');
    final categoryCounts = <String, int>{};
    for (final entry in expenseTransactions) {
      categoryCounts.update(entry.categoryId, (value) => value + 1,
          ifAbsent: () => 1);
    }
    final categoryIndex = {for (final category in categories) category.id: category};
    final categorySummary = categoryTotals.entries
        .map(
          (entry) => _CategorySummaryItem(
            id: entry.key,
            name: categoryIndex[entry.key]?.name ?? 'Unknown',
            color: categoryIndex[entry.key]?.color,
            icon: categoryIndex[entry.key]?.icon,
            count: categoryCounts[entry.key] ?? 0,
            total: entry.value,
          ),
        )
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));
    final formatter = NumberFormat.currency(symbol: '৳');
    final total = summary.income + summary.expense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
          tooltip: 'Back',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const DateFilterBar(title: 'Report Range'),
          const SizedBox(height: 16),
          Text('Overview', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (total == 0)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No data for this range yet.'),
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Income vs Expense'),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: PieChart(
                        PieChartData(
                          sections: _buildPieSections(summary, context),
                          centerSpaceRadius: 32,
                          sectionsSpace: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _LegendRow(
                      color: const Color(0xFF16A34A),
                      label: 'Income ${formatter.format(summary.income)}',
                    ),
                    const SizedBox(height: 4),
                    _LegendRow(
                      color: const Color(0xFFDC2626),
                      label: 'Expense ${formatter.format(summary.expense)}',
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text('Monthly Spending', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (monthlySpending.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No monthly data yet.'),
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 240,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceBetween,
                      maxY: _maxMonthlyTotal(monthlySpending),
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) => Text(
                              value.toStringAsFixed(0),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= monthlySpending.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  DateFormat.MMM().format(
                                    monthlySpending[index].month,
                                  ),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: true),
                      barGroups: _buildMonthlyBars(monthlySpending),
                    ),
                  ),
                ),
              ),
            ),
          Text(
            'Category Summary',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (categorySummary.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No report data yet.'),
              ),
            )
          else
            Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Summary'),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 220,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  sections: _buildCategorySections(
                                    categorySummary,
                                  ),
                                  centerSpaceRadius: 58,
                                  sectionsSpace: 4,
                                  startDegreeOffset: -90,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Amount',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatter.format(
                                      categorySummary.fold<double>(
                                        0,
                                        (sum, item) => sum + item.total,
                                      ),
                                    ),
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: categorySummary.map((item) {
                            return _LegendRow(
                              color: item.resolvedColor,
                              label: item.name,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...categorySummary.map(
                  (item) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: item.resolvedColor.withOpacity(0.15),
                        child: Icon(
                          item.iconData,
                          color: item.resolvedColor,
                        ),
                      ),
                      title: Text(item.name),
                      subtitle: Text('${item.count} transactions'),
                      trailing: Text(formatter.format(item.total)),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

List<PieChartSectionData> _buildPieSections(
  IncomeExpenseSummary summary,
  BuildContext context,
) {
  final total = summary.income + summary.expense;
  if (total == 0) {
    return [
      PieChartSectionData(
        value: 1,
        color: Colors.grey.shade300,
        title: 'No data',
        radius: 48,
        titleStyle: Theme.of(context).textTheme.bodySmall,
      ),
    ];
  }

  return [
    PieChartSectionData(
      value: summary.income,
      color: const Color(0xFF16A34A),
      title: '${(summary.income / total * 100).toStringAsFixed(0)}%',
      radius: 56,
      titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
    ),
    PieChartSectionData(
      value: summary.expense,
      color: const Color(0xFFDC2626),
      title: '${(summary.expense / total * 100).toStringAsFixed(0)}%',
      radius: 56,
      titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
    ),
  ];
}

double _maxMonthlyTotal(List<MonthlySpending> monthlySpending) {
  if (monthlySpending.isEmpty) {
    return 1;
  }
  final maxValue = monthlySpending.map((entry) => entry.total).reduce(max);
  return maxValue == 0 ? 1 : maxValue * 1.2;
}

List<BarChartGroupData> _buildMonthlyBars(
  List<MonthlySpending> monthlySpending,
) {
  return monthlySpending.asMap().entries.map((entry) {
    final index = entry.key;
    final total = entry.value.total;
    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: total,
          color: const Color(0xFF0F766E),
          width: 14,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }).toList();
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}

class _CategorySummaryItem {
  _CategorySummaryItem({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    required this.count,
    required this.total,
  });

  final String id;
  final String name;
  final int? color;
  final int? icon;
  final int count;
  final double total;

  Color get resolvedColor {
    if (color != null) {
      return Color(color!);
    }
    const fallback = [
      Color(0xFF2563EB),
      Color(0xFFF59E0B),
      Color(0xFF7C3AED),
      Color(0xFF10B981),
      Color(0xFFF97316),
      Color(0xFF06B6D4),
    ];
    return fallback[id.hashCode.abs() % fallback.length];
  }

  IconData get iconData {
    if (icon != null) {
      return IconData(icon!, fontFamily: 'MaterialIcons');
    }
    return Icons.category;
  }
}

List<PieChartSectionData> _buildCategorySections(
  List<_CategorySummaryItem> items,
) {
  return items
      .map(
        (item) => PieChartSectionData(
          value: item.total,
          color: item.resolvedColor,
          title: '',
          radius: 48,
        ),
      )
      .toList();
}
