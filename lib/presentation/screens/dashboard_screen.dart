import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/utils/transaction_calculations.dart';
import '../providers/providers.dart';
import 'add_transaction_sheet.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final now = DateTime.now();
    final todayExpense =
        TransactionCalculations.dailyTotalExpense(transactions, now);
    final monthlyIncome =
        TransactionCalculations.monthlyTotal(transactions, now.month, now.year, 'income');
    final monthlyExpense =
        TransactionCalculations.monthlyTotal(transactions, now.month, now.year, 'expense');
    final formatter = NumberFormat.currency(symbol: '৳');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Expense Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => context.go('/reports'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Today Expense',
                  value: formatter.format(todayExpense),
                  icon: Icons.today,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  title: 'This Month Income',
                  value: formatter.format(monthlyIncome),
                  icon: Icons.arrow_downward,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SummaryCard(
            title: 'This Month Expense',
            value: formatter.format(monthlyExpense),
            icon: Icons.arrow_upward,
          ),
          const SizedBox(height: 20),
          Text('Recent Transactions', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (transactions.isEmpty)
            const _EmptyState(message: 'No transactions yet. Add your first entry!')
          else
            ...transactions.take(5).map(
                  (entry) => ListTile(
                    leading: CircleAvatar(
                      child: Icon(
                        entry.type == 'income'
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                      ),
                    ),
                    title: Text(entry.note.isEmpty ? 'No note' : entry.note),
                    subtitle: Text(DateFormat.yMMMd().format(entry.date)),
                    trailing: Text(formatter.format(entry.amount)),
                  ),
                ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.category_outlined),
                  label: const Text('Categories'),
                  onPressed: () => context.go('/categories'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  label: const Text('Budget'),
                  onPressed: () => context.go('/budget'),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (context) => const AddTransactionSheet(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(child: Icon(icon)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 4),
                  Text(value, style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.inbox_outlined, size: 40),
            const SizedBox(height: 8),
            Text(message),
          ],
        ),
      ),
    );
  }
}
