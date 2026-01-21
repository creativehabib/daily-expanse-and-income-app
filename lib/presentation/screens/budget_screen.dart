import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final budgetAsync = ref.watch(budgetProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Budget')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            budgetAsync.when(
              data: (budget) {
                if (budget != null) {
                  _budgetController.text = budget.totalBudget.toStringAsFixed(0);
                }
                return Text(
                  budget == null
                      ? 'No budget set for this month.'
                      : 'Current budget: ${budget.totalBudget.toStringAsFixed(0)}',
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: TextFormField(
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
            ),
            const SizedBox(height: 12),
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
                },
                child: const Text('Save Budget'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
