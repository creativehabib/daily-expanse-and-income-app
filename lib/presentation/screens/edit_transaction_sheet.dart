import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/transaction_entry.dart';
import '../providers/providers.dart';
import '../utils/currency_utils.dart';

class EditTransactionSheet extends ConsumerStatefulWidget {
  const EditTransactionSheet({super.key, required this.entry});

  final TransactionEntry entry;

  @override
  ConsumerState<EditTransactionSheet> createState() =>
      _EditTransactionSheetState();
}

class _EditTransactionSheetState extends ConsumerState<EditTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'expense';
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    _type = widget.entry.type;
    _categoryId = widget.entry.categoryId;
    _amountController.text = formatNumber(widget.entry.amount);
    _noteController.text = widget.entry.note;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final settings = ref.watch(settingsProvider);
    final currencySymbol = currencySymbolFor(settings.currency);
    final filteredCategories = categories
        .where((category) => category.type == _type || category.type == 'both')
        .toList();

    if (_categoryId != null &&
        !filteredCategories.any((category) => category.id == _categoryId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _categoryId = null);
        }
      });
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Transaction',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'expense', label: Text('Expense')),
                ButtonSegment(value: 'income', label: Text('Income')),
              ],
              selected: {_type},
              onSelectionChanged: (value) {
                setState(() {
                  _type = value.first;
                  _categoryId = null;
                });
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _amountController,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: currencySymbol.isEmpty ? null : '$currencySymbol ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter amount';
                if (double.tryParse(value) == null) return 'Invalid amount';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _categoryId,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              items: filteredCategories
                  .map((category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _categoryId = value),
              validator: (value) => value == null ? 'Please select category' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: () async {
                  if (!(_formKey.currentState?.validate() ?? false)) return;

                  final updatedEntry = widget.entry.copyWith(
                    type: _type,
                    amount: double.parse(_amountController.text),
                    categoryId: _categoryId!,
                    note: _noteController.text,
                  );

                  await ref
                      .read(transactionsProvider.notifier)
                      .update(updatedEntry);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Update Transaction'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
