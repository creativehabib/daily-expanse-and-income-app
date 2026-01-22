import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/transaction_entry.dart';
import '../providers/providers.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  ConsumerState<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _amountFocusNode = FocusNode();
  final _noteController = TextEditingController();
  String _type = 'expense';
  String? _categoryId;

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

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
            Text('Add Transaction', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'expense', label: Text('Expense')),
                ButtonSegment(value: 'income', label: Text('Income')),
              ],
              selected: {_type},
              onSelectionChanged: (value) {
                setState(() => _type = value.first);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              focusNode: _amountFocusNode,
              decoration: InputDecoration(
                labelText: 'Amount',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calculate),
                  tooltip: 'Calculator',
                  onPressed: () {
                    _openCalculator(context);
                  },
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Invalid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _categoryId,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: categories
                  .where((category) =>
                      category.type == _type || category.type == 'both')
                  .map((category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _categoryId = value),
              validator: (value) =>
                  value == null ? 'Please select category' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  if (!(_formKey.currentState?.validate() ?? false)) {
                    return;
                  }

                  final entry = TransactionEntry(
                    id: const Uuid().v4(),
                    type: _type,
                    amount: double.parse(_amountController.text),
                    categoryId: _categoryId!,
                    note: _noteController.text,
                    date: DateTime.now(),
                    paymentMethod: null,
                    createdAt: DateTime.now(),
                  );

                  await ref.read(transactionsProvider.notifier).add(entry);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _openCalculator(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final result = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CalculatorSheet(
        initialValue: _amountController.text,
      ),
    );
    if (result != null) {
      _amountController.text = _formatNumber(result);
      _amountFocusNode.requestFocus();
    }
  }
}

class _CalculatorSheet extends StatefulWidget {
  const _CalculatorSheet({required this.initialValue});

  final String initialValue;

  @override
  State<_CalculatorSheet> createState() => _CalculatorSheetState();
}

class _CalculatorSheetState extends State<_CalculatorSheet> {
  late String _expression;

  @override
  void initState() {
    super.initState();
    _expression = widget.initialValue.trim();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'Calculator',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Text(
                _expression.isEmpty ? '0' : _expression,
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.25,
              children: [
                _buildButton('AC', _clear, style: _ButtonStyle.secondary),
                _buildButton('⌫', _backspace, style: _ButtonStyle.secondary),
                _buildButton('%', _percent, style: _ButtonStyle.secondary),
                _buildButton('÷', () => _append('÷'),
                    style: _ButtonStyle.operator),
                _buildButton('7', () => _append('7')),
                _buildButton('8', () => _append('8')),
                _buildButton('9', () => _append('9')),
                _buildButton('×', () => _append('×'),
                    style: _ButtonStyle.operator),
                _buildButton('4', () => _append('4')),
                _buildButton('5', () => _append('5')),
                _buildButton('6', () => _append('6')),
                _buildButton('-', () => _append('-'),
                    style: _ButtonStyle.operator),
                _buildButton('1', () => _append('1')),
                _buildButton('2', () => _append('2')),
                _buildButton('3', () => _append('3')),
                _buildButton('+', () => _append('+'),
                    style: _ButtonStyle.operator),
                _buildButton('.', () => _append('.'),
                    style: _ButtonStyle.secondary),
                _buildButton('0', () => _append('0')),
                _buildButton('=', _evaluate, style: _ButtonStyle.operator),
                _buildButton('OK', _submit, style: _ButtonStyle.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    String label,
    VoidCallback onPressed, {
    _ButtonStyle style = _ButtonStyle.standard,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    Color backgroundColor;
    Color foregroundColor;

    switch (style) {
      case _ButtonStyle.primary:
        backgroundColor = colorScheme.primary;
        foregroundColor = colorScheme.onPrimary;
        break;
      case _ButtonStyle.operator:
        backgroundColor = colorScheme.primaryContainer;
        foregroundColor = colorScheme.onPrimaryContainer;
        break;
      case _ButtonStyle.secondary:
        backgroundColor = colorScheme.surfaceContainerHighest;
        foregroundColor = colorScheme.onSurface;
        break;
      case _ButtonStyle.standard:
        backgroundColor = colorScheme.surface;
        foregroundColor = colorScheme.onSurface;
        break;
    }

    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: Theme.of(context).textTheme.titleMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }

  void _append(String value) {
    setState(() {
      _expression += value;
    });
  }

  void _clear() {
    setState(() {
      _expression = '';
    });
  }

  void _backspace() {
    if (_expression.isEmpty) {
      return;
    }
    setState(() {
      _expression = _expression.substring(0, _expression.length - 1);
    });
  }

  void _percent() {
    final value = _evaluateExpression(_expression);
    if (value == null) {
      return;
    }
    setState(() {
      _expression = _formatNumber(value / 100);
    });
  }

  void _evaluate() {
    final value = _evaluateExpression(_expression);
    if (value == null) {
      return;
    }
    setState(() {
      _expression = _formatNumber(value);
    });
  }

  void _submit() {
    final value = _evaluateExpression(_expression);
    if (value == null) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pop(value);
  }
}

enum _ButtonStyle { standard, secondary, operator, primary }

double? _evaluateExpression(String expression) {
  if (expression.trim().isEmpty) {
    return 0;
  }

  final sanitized = expression.replaceAll('×', '*').replaceAll('÷', '/');
  final tokens = <String>[];
  final buffer = StringBuffer();
  String? previousToken;

  for (var i = 0; i < sanitized.length; i++) {
    final char = sanitized[i];
    if ('0123456789.'.contains(char)) {
      buffer.write(char);
      continue;
    }

    if ('+-*/'.contains(char)) {
      if (buffer.isEmpty && (char == '-') && (previousToken == null || '+-*/'.contains(previousToken!))) {
        buffer.write(char);
        continue;
      }
      if (buffer.isNotEmpty) {
        tokens.add(buffer.toString());
        buffer.clear();
      }
      tokens.add(char);
      previousToken = char;
    }
  }

  if (buffer.isNotEmpty) {
    tokens.add(buffer.toString());
  }

  if (tokens.isEmpty) {
    return null;
  }

  final values = <double>[];
  final operators = <String>[];

  for (final token in tokens) {
    if ('+-*/'.contains(token)) {
      while (operators.isNotEmpty &&
          _precedence(operators.last) >= _precedence(token)) {
        final result = _applyOperation(
          operators.removeLast(),
          values.removeLast(),
          values.removeLast(),
        );
        if (result == null) {
          return null;
        }
        values.add(result);
      }
      operators.add(token);
    } else {
      final value = double.tryParse(token);
      if (value == null) {
        return null;
      }
      values.add(value);
    }
  }

  while (operators.isNotEmpty) {
    final result = _applyOperation(
      operators.removeLast(),
      values.removeLast(),
      values.removeLast(),
    );
    if (result == null) {
      return null;
    }
    values.add(result);
  }

  return values.isEmpty ? null : values.last;
}

int _precedence(String operator) {
  if (operator == '*' || operator == '/') {
    return 2;
  }
  return 1;
}

double? _applyOperation(String operator, double b, double a) {
  switch (operator) {
    case '+':
      return a + b;
    case '-':
      return a - b;
    case '*':
      return a * b;
    case '/':
      if (b == 0) {
        return null;
      }
      return a / b;
  }
  return null;
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toString();
}
