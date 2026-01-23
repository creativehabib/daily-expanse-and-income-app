import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../domain/models/category.dart';
import '../../domain/utils/transaction_calculations.dart';
import '../providers/providers.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _budgetController = TextEditingController();

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final budgetAsync = ref.watch(budgetProvider);
    final transactions = ref.watch(transactionsProvider);
    final categories = ref.watch(categoriesProvider);
    final now = DateTime.now();

    final monthlyExpenses = transactions
        .where((entry) => entry.type == 'expense')
        .where((entry) => entry.date.month == now.month && entry.date.year == now.year)
        .toList();

    final totalExpense = monthlyExpenses.fold<double>(
      0,
      (sum, entry) => sum + entry.amount,
    );

    final formatter = NumberFormat.currency(symbol: '৳');

    final categoryLookup = {
      for (final category in categories) category.id: category,
    };

    final categoryTotals = TransactionCalculations.categoryTotals(
      monthlyExpenses,
      'expense',
    );

    final categorySpending = categoryTotals.entries.map((entry) {
      final category = categoryLookup[entry.key];
      return _CategorySpending(
        name: category?.name ?? 'Unknown',
        amount: entry.value,
        icon: category == null
            ? Icons.category_outlined
            : IconData(category.icon, fontFamily: 'MaterialIcons'),
        color: category == null ? Colors.blueGrey : Color(category.color),
      );
    }).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Budget Summary',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
          tooltip: 'Back',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          budgetAsync.when(
            data: (budget) {
              return _BudgetSummaryCard(
                monthLabel: DateFormat('MMMM yyyy').format(now),
                totalBudget: budget?.totalBudget ?? 0,
                totalExpense: totalExpense,
                formatter: formatter,
                onEdit: () => _openBudgetEditor(context, budget?.totalBudget),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (error, stack) => Text('Error: $error'),
          ),
          const SizedBox(height: 24),
          Text(
            'Spending by category',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 12),
          if (categorySpending.isEmpty)
            _EmptyBudgetState(
              message: 'No expense entries for ${DateFormat('MMMM').format(now)} yet.',
            )
          else
            ...categorySpending.map(
              (entry) => _CategorySpendTile(
                spending: entry,
                totalExpense: totalExpense,
                formatter: formatter,
              ),
            ),
        ],
      ),
    );
  }

  void _openBudgetEditor(BuildContext context, double? currentBudget) {
    _budgetController.text = currentBudget?.toStringAsFixed(0) ?? '';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set monthly budget',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _budgetController,
                  decoration: const InputDecoration(
                    labelText: 'Total Monthly Budget',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter budget';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Invalid budget';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      if (!(_formKey.currentState?.validate() ?? false)) {
                        return;
                      }
                      final now = DateTime.now();
                      await ref.read(budgetRepositoryProvider).upsert(
                            month: now.month,
                            year: now.year,
                            totalBudget: double.parse(_budgetController.text),
                          );
                      ref.invalidate(budgetProvider);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Save Budget'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BudgetSummaryCard extends StatelessWidget {
  const _BudgetSummaryCard({
    required this.monthLabel,
    required this.totalBudget,
    required this.totalExpense,
    required this.formatter,
    required this.onEdit,
  });

  final String monthLabel;
  final double totalBudget;
  final double totalExpense;
  final NumberFormat formatter;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onPrimary = colorScheme.onPrimary;
    final onPrimaryMuted = colorScheme.onPrimary.withOpacity(0.75);
    final progressBackground = onPrimary.withOpacity(0.2);
    final hasBudget = totalBudget > 0;
    final remaining = TransactionCalculations.remainingBudget(
      totalBudget: totalBudget,
      totalExpense: totalExpense,
    );
    final percent = hasBudget ? (totalExpense / totalBudget) : 0.0;
    final percentValue = percent.clamp(0.0, 1.0).toDouble();
    final percentLabel = hasBudget ? (percent * 100).toStringAsFixed(0) : '0';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budgets Summary',
                    style: GoogleFonts.poppins(
                      color: onPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    monthLabel,
                    style: GoogleFonts.poppins(
                      color: onPrimaryMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  foregroundColor: onPrimary,
                  backgroundColor: onPrimary.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                icon: const Icon(Icons.edit, size: 16),
                label: Text(
                  hasBudget ? 'Edit' : 'Set',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                height: 72,
                width: 72,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: hasBudget ? percentValue : 0.0,
                      strokeWidth: 8,
                      backgroundColor: progressBackground,
                      valueColor: AlwaysStoppedAnimation<Color>(onPrimary),
                    ),
                    Center(
                      child: Text(
                        '$percentLabel%',
                        style: GoogleFonts.poppins(
                          color: onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My budget',
                      style: GoogleFonts.poppins(
                        color: onPrimaryMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${formatter.format(totalExpense)} from ${formatter.format(totalBudget)}',
                      style: GoogleFonts.poppins(
                        color: onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      hasBudget
                          ? '${formatter.format(remaining)} remaining'
                          : 'Set a budget to track remaining',
                      style: GoogleFonts.poppins(
                        color: onPrimaryMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategorySpending {
  const _CategorySpending({
    required this.name,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String name;
  final double amount;
  final IconData icon;
  final Color color;
}

class _CategorySpendTile extends StatelessWidget {
  const _CategorySpendTile({
    required this.spending,
    required this.totalExpense,
    required this.formatter,
  });

  final _CategorySpending spending;
  final double totalExpense;
  final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final percent = totalExpense > 0 ? spending.amount / totalExpense : 0.0;
    final percentValue = percent.clamp(0.0, 1.0).toDouble();

    final iconBackground = spending.color.withOpacity(
      theme.brightness == Brightness.dark ? 0.3 : 0.15,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(spending.icon, color: spending.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      spending.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatter.format(spending.amount),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(percent * 100).toStringAsFixed(0)}%',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentValue,
              minHeight: 6,
              backgroundColor: iconBackground,
              valueColor: AlwaysStoppedAnimation<Color>(spending.color),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBudgetState extends StatelessWidget {
  const _EmptyBudgetState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
