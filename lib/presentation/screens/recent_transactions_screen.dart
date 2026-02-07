import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../domain/models/transaction_entry.dart';
import '../providers/date_filter_provider.dart';
import '../providers/providers.dart';
import '../utils/currency_utils.dart';
import '../widgets/date_filter_bar.dart';
import '../widgets/transaction_tile.dart';
import 'edit_transaction_sheet.dart';

enum _TransactionAction { edit, delete }

class RecentTransactionsScreen extends ConsumerWidget {
  const RecentTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final currencySymbol = currencySymbolFor(settings.currency);
    final formatter = NumberFormat.currency(symbol: currencySymbol);
    final orderedTransactions = ref.watch(orderedTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Transactions'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const DateFilterBar(),
          const SizedBox(height: 16),
          if (orderedTransactions.isEmpty)
            const _EmptyStateCard(
              message: 'No transactions match this filter yet.',
            )
          else
            ...orderedTransactions.map((entry) => TransactionTile(
                  title: entry.note.isEmpty ? 'No note' : entry.note,
                  date: DateFormat.yMMMd().format(entry.date),
                  amount: formatter.format(entry.amount),
                  isIncome: entry.type == 'income',
                  onTap: () => _openEditSheet(context, entry),
                  action: PopupMenuButton<_TransactionAction>(
                    onSelected: (action) => _handleAction(
                      context,
                      ref,
                      action,
                      entry,
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: _TransactionAction.edit,
                        child: ListTile(
                          leading: FaIcon(FontAwesomeIcons.penToSquare, size: 16),
                          title: Text('Edit'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: _TransactionAction.delete,
                        child: ListTile(
                          leading: FaIcon(FontAwesomeIcons.trash, color: Colors.red, size: 16),
                          title: Text('Delete'),
                        ),
                      ),
                    ],
                  ),
                )),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _handleAction(
    BuildContext context,
    WidgetRef ref,
    _TransactionAction action,
    TransactionEntry entry,
  ) {
    switch (action) {
      case _TransactionAction.edit:
        _openEditSheet(context, entry);
        break;
      case _TransactionAction.delete:
        _confirmDelete(context, ref, entry);
        break;
    }
  }

  void _openEditSheet(BuildContext context, TransactionEntry entry) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditTransactionSheet(entry: entry),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    TransactionEntry entry,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await ref.read(transactionsProvider.notifier).remove(entry.id);
    }
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const FaIcon(
            FontAwesomeIcons.inbox,
            size: 36,
            color: Color(0xFF0F766E),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
