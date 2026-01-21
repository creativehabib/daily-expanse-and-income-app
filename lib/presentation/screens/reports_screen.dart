import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/utils/transaction_calculations.dart';
import '../providers/providers.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final categoryTotals =
        TransactionCalculations.categoryTotals(transactions, 'expense');
    final formatter = NumberFormat.currency(symbol: '৳');

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
          Text('Top Categories', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (categoryTotals.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No report data yet.'),
              ),
            )
          else
            ...categoryTotals.entries.map(
              (entry) => Card(
                child: ListTile(
                  title: Text('Category ${entry.key.substring(0, 6)}'),
                  trailing: Text(formatter.format(entry.value)),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Charts Placeholder'),
                  SizedBox(height: 8),
                  Text('Integrate charts like fl_chart or syncfusion later.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
